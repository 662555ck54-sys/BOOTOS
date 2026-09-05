import json
import os
import threading
import urllib.request
import tkinter as tk
from tkinter import filedialog, messagebox, simpledialog

APP_NAME = "OSBoot"
APP_VERSION = "1.0.0"
ONLINE_DATABASE_URL = "https://raw.githubusercontent.com/YOURNAME/OSBoot/main/os_database.json"
DB_FILE = "os_database.json"

class OSBoot:
    def __init__(self, root):
        self.root = root
        self.root.title(f"{APP_NAME} {APP_VERSION}")
        self.root.geometry("900x560")
        self.root.minsize(760, 480)
        self.root.configure(bg="#111318")
        self.database = self.load_database()
        self.filtered_os = list(self.database)
        self.selected_os = None
        self.build_ui()
        self.refresh_os_list()
        self.root.after(500, self.update_database)

    def load_database(self):
        try:
            with open(DB_FILE, "r", encoding="utf-8") as f:
                data = json.load(f)
            return data if isinstance(data, dict) else {}
        except Exception:
            return {}

    def build_ui(self):
        tk.Label(self.root, text="OSBoot", font=("Segoe UI",28,"bold"),
                 fg="white", bg="#111318").pack(pady=(20,0))
        tk.Label(self.root, text="Simple operating-system launcher",
                 font=("Segoe UI",11), fg="#9ca3af", bg="#111318").pack(pady=(0,14))

        top = tk.Frame(self.root, bg="#111318"); top.pack(fill="x", padx=24)
        self.search = tk.Entry(top, font=("Segoe UI",12), bg="#20242c",
                               fg="white", insertbackground="white", relief="flat")
        self.search.pack(fill="x", expand=True, ipady=8)
        self.search.insert(0, "Search OS or version...")
        self.search.bind("<FocusIn>", self.clear_placeholder)
        self.search.bind("<KeyRelease>", lambda e: self.refresh_os_list())

        body = tk.Frame(self.root, bg="#111318"); body.pack(fill="both", expand=True, padx=24, pady=18)
        left = tk.Frame(body, bg="#191d24"); left.pack(side="left", fill="both", expand=True, padx=(0,9))
        right = tk.Frame(body, bg="#191d24"); right.pack(side="left", fill="both", expand=True, padx=(9,0))

        tk.Label(left,text="Operating Systems",font=("Segoe UI",12,"bold"),fg="white",bg="#191d24").pack(anchor="w",padx=12,pady=12)
        self.os_list = tk.Listbox(left,bg="#191d24",fg="white",selectbackground="#3b82f6",
                                  borderwidth=0,highlightthickness=0,font=("Segoe UI",11))
        self.os_list.pack(fill="both",expand=True,padx=8,pady=(0,8))
        self.os_list.bind("<<ListboxSelect>>",self.select_os)

        tk.Label(right,text="Versions / Images",font=("Segoe UI",12,"bold"),fg="white",bg="#191d24").pack(anchor="w",padx=12,pady=12)
        self.version_list = tk.Listbox(right,bg="#191d24",fg="white",selectbackground="#3b82f6",
                                       borderwidth=0,highlightthickness=0,font=("Segoe UI",11))
        self.version_list.pack(fill="both",expand=True,padx=8,pady=(0,8))

        buttons = tk.Frame(self.root,bg="#111318"); buttons.pack(fill="x",padx=24,pady=(0,10))
        tk.Button(buttons,text="Check for Updates",command=self.update_database,bg="#252a34",fg="white",relief="flat",padx=14,pady=8).pack(side="left")
        tk.Button(buttons,text="Add Custom OS",command=self.add_custom_os,bg="#252a34",fg="white",relief="flat",padx=14,pady=8).pack(side="left",padx=8)
        tk.Button(buttons,text="Add ISO / IMG",command=self.add_image,bg="#252a34",fg="white",relief="flat",padx=14,pady=8).pack(side="left")
        tk.Button(buttons,text="Continue",command=self.continue_boot,bg="#2563eb",fg="white",relief="flat",padx=22,pady=8).pack(side="right")

        self.status = tk.Label(self.root,text="Ready",anchor="w",fg="#9ca3af",bg="#0d0f13",padx=10,pady=7)
        self.status.pack(fill="x",side="bottom")

    def clear_placeholder(self,event=None):
        if self.search.get() == "Search OS or version...":
            self.search.delete(0,"end")

    def refresh_os_list(self):
        query = self.search.get().lower()
        if query == "search os or version...": query = ""
        self.filtered_os = [name for name, versions in self.database.items()
                            if query in name.lower() or any(query in v.lower() for v in versions)]
        self.os_list.delete(0,"end")
        for name in self.filtered_os: self.os_list.insert("end",name)
        if self.filtered_os:
            self.os_list.selection_set(0)
            self.select_os()

    def select_os(self,event=None):
        selection = self.os_list.curselection()
        if not selection: return
        self.selected_os = self.filtered_os[selection[0]]
        self.version_list.delete(0,"end")
        query = self.search.get().lower()
        if query == "search os or version...": query = ""
        for version in self.database[self.selected_os]:
            if query in version.lower() or query in self.selected_os.lower():
                self.version_list.insert("end",version)

    def add_custom_os(self):
        name = simpledialog.askstring("Custom OS","Operating system name:")
        if not name: return
        version = simpledialog.askstring("Custom OS","Version:")
        if not version: return
        self.database.setdefault(name,[])
        if version not in self.database[name]: self.database[name].append(version)
        self.save_database()
        self.refresh_os_list()
        self.status.config(text=f"Added {name} {version}")

    def add_image(self):
        path = filedialog.askopenfilename(
            title="Select OS image",
            filetypes=[("OS images","*.iso *.img *.efi *.vhd *.vhdx"),
                       ("ISO files","*.iso"),("IMG files","*.img"),("EFI files","*.efi"),
                       ("Virtual disks","*.vhd *.vhdx"),("All files","*.*")]
        )
        if not path: return
        name = simpledialog.askstring("Add Image","OS name:",initialvalue="Custom OS")
        if not name: return
        version = simpledialog.askstring("Add Image","Version / label:",initialvalue=os.path.basename(path))
        if not version: return
        self.database.setdefault(name,[])
        self.database[name].append(f"{version} — {path}")
        self.save_database()
        self.refresh_os_list()
        self.status.config(text=f"Added image: {os.path.basename(path)}")

    def save_database(self):
        with open(DB_FILE,"w",encoding="utf-8") as f:
            json.dump(self.database,f,indent=2)

    def update_database(self):
        self.status.config(text="Checking for OS database updates...")
        threading.Thread(target=self._download_database,daemon=True).start()

    def _download_database(self):
        try:
            with urllib.request.urlopen(ONLINE_DATABASE_URL,timeout=5) as response:
                data=json.loads(response.read().decode("utf-8"))
            if isinstance(data,dict):
                with open(DB_FILE,"w",encoding="utf-8") as f: json.dump(data,f,indent=2)
                self.root.after(0,self._database_updated)
                return
        except Exception:
            pass
        self.root.after(0,lambda:self.status.config(text="Using local OS database (online database unavailable)."))

    def _database_updated(self):
        self.database=self.load_database()
        self.refresh_os_list()
        self.status.config(text="OS database updated.")

    def continue_boot(self):
        if not self.selected_os or not self.version_list.curselection():
            messagebox.showinfo("OSBoot","Select an operating system and version first.")
            return
        version=self.version_list.get(self.version_list.curselection()[0])
        messagebox.showinfo("OSBoot",f"Selected:\n\n{self.selected_os}\n{version}\n\nBoot functionality is not enabled in this demo yet.")

if __name__ == "__main__":
    root=tk.Tk()
    OSBoot(root)
    root.mainloop()
