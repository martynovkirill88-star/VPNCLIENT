import sys
import plistlib
import os

if len(sys.argv) < 2:
    print("Usage: fix_plist.py <path_to_plist>")
    sys.exit(0)

plist_path = sys.argv[1]
if not os.path.exists(plist_path):
    print(f"Plist not found at {plist_path}")
    sys.exit(0)

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
