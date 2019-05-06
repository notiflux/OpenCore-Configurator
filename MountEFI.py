#!/usr/bin/env python
# 0.0.0
# based on CorpNewt's MountEFI at https://github.com/CorpNewt/MountEFI
from Scripts import disk
import os, tempfile, datetime, shutil, time, plistlib, json, sys, argparse

class MountEFI:
    def __init__(self, **kwargs):
        #self.r  = run.Run()
        self.d  = disk.Disk()
        #self.dl = downloader.Downloader()
        #self.u  = utils.Utils("MountEFI")
        #self.re = reveal.Reveal()
        # Get the tools we need
        self.script_folder = "Scripts"
        self.update_url = "https://raw.githubusercontent.com/corpnewt/MountEFIv2/master/MountEFI.command"
        
        self.settings_file = kwargs.get("settings", None)
        cwd = os.getcwd()
        os.chdir(os.path.dirname(os.path.realpath(__file__)))
        if self.settings_file and os.path.exists(self.settings_file):
            self.settings = json.load(open(self.settings_file))
        else:
            self.settings = {
                # Default settings here
                "default_disk" : None,
                "after_mount"  : None,
                "full_layout"  : False,
                "skip_countdown" : False,
            }
        os.chdir(cwd)
        self.full = self.settings.get("full_layout", False)
        
    def get_efi(self):
        self.d.update()
        i = 0
        disk_string = ""
        if not self.full:
            mounts = self.d.get_mounted_volume_dicts()
            for d in mounts:
                i += 1
                disk_string += "{}. {} ({})".format(i, d["name"], d["identifier"])
                disk_string += "\n"
        else:
            mounts = self.d.get_disks_and_partitions_dict()
            disks = mounts.keys()
            for d in disks:
                i += 1
                disk_string+= "{}. {}:\n".format(i, d)
                parts = mounts[d]["partitions"]
                part_list = []
                for p in parts:
                    p_text = "        - {} ({})".format(p["name"], p["identifier"])
                    part_list.append(p_text)
                if len(part_list):
                    disk_string += "\n".join(part_list) + "\n"
        height = len(disk_string.split("\n"))+16
        if height < 24:
            height = 24
        print(disk_string)
        exit()

    def main(self):
        while True:
            efi = self.get_efi()
            if not efi:
                # Got nothing back
                continue
            # Mount the EFI partition
            self.u.head("Mounting {}".format(efi))
            # print(" ")
            out = self.d.mount_partition(efi)
            if out[2] == 0:
                print(out[0])
            else:
                print(out[1])
            # Check our settings
            am = self.settings.get("after_mount", None)
            if not am:
                continue
            if "reveal" in am.lower():
                # Reveal
                mp = self.d.get_mount_point(efi)
                if mp:
                    self.r.run({"args":["open", mp]})
            # Hang out for a couple seconds
            if not self.settings.get("skip_countdown", False):
                self.u.grab("", timeout=3)
            if "quit" in am.lower():
                # Quit
                self.u.resize(80,24)
                self.u.custom_quit()

    def quiet_mount(self, disk_list, unmount=False):
        ret = 0
        for disk in disk_list:
            ident = self.d.get_identifier(disk)
            if not ident:
                continue
            efi = self.d.get_efi(ident)
            if not efi:
                continue
            if unmount:
                out = self.d.unmount_partition(efi)
            else:
                out = self.d.mount_partition(efi)
            if not out[2] == 0:
                ret = out[2]
        exit(ret)

if __name__ == '__main__':
    # Setup the cli args
    parser = argparse.ArgumentParser(prog="MountEFI.command", description="MountEFI - an EFI Mounting Utility by CorpNewt")
    parser.add_argument("-u", "--unmount", help="unmount instead of mount the passed EFIs", action="store_true")
    parser.add_argument("-p", "--print-efi", help="prints the disk#s# of the EFI attached to the passed var")
    parser.add_argument("disks",nargs="*")

    args = parser.parse_args()

    m = MountEFI(settings="./Scripts/settings.json")
    # Gather defaults
    unmount = False
    if args.unmount:
        unmount = True
    if args.print_efi:
        print("{}".format(m.d.get_efi(args.print_efi)))
    # Check for args
    if len(args.disks):
        # We got command line args!
        m.quiet_mount(args.disks, unmount)
    elif not args.print_efi:
        m.main()
