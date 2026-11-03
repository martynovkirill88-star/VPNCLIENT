import sys
import plistlib
import os

def fix_extension_plist(plist_path):
    if not os.path.exists(plist_path):
        print(f"Extension Plist not found at {plist_path}")
        return
    with open(plist_path, 'rb') as f:
        data = plistlib.load(f)
    
    data['CFBundlePackageType'] = 'XPC!'
    data['NSExtension'] = {
        'NSExtensionPointIdentifier': 'com.apple.networkextension.packet-tunnel',
        'NSExtensionPrincipalClass': 'PacketTunnel.PacketTunnelProvider'
    }
    with open(plist_path, 'wb') as f:
        plistlib.dump(data, f)
    print(f"✅ Successfully injected NSExtension into: {plist_path}")

def fix_app_plist(plist_path):
    if not os.path.exists(plist_path):
        print(f"App Plist not found at {plist_path}")
        return
    with open(plist_path, 'rb') as f:
        data = plistlib.load(f)
    
    data['CFBundlePackageType'] = 'APPL'
    data['UILaunchStoryboardName'] = 'LaunchScreen'
    # Remove any empty UILaunchScreen dict if present to prevent conflict
    if 'UILaunchScreen' in data and not data['UILaunchScreen']:
        del data['UILaunchScreen']
        
    with open(plist_path, 'wb') as f:
        plistlib.dump(data, f)
    print(f"✅ Successfully injected UILaunchStoryboardName into: {plist_path}")

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: fix_plist.py <path_to_app_or_plist>")
        sys.exit(0)
    
    target = sys.argv[1]
    if os.path.isdir(target):
        # Passed Payload/VPNClientApp.app
        app_plist = os.path.join(target, "Info.plist")
        fix_app_plist(app_plist)
        ext_plist = os.path.join(target, "PlugIns", "PacketTunnel.appex", "Info.plist")
        fix_extension_plist(ext_plist)
    else:
        # Direct file passed
        if "PacketTunnel" in target:
            fix_extension_plist(target)
        else:
            fix_app_plist(target)
