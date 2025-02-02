#!/bin/sh

# switch to root user
sudo -i


# remove snap packages and snap service all together
remove_snap() {
    echo "Removing all Snap packages..."
    # Get a list of all installed snap packages
    local packages
    packages=$(snap list | awk 'NR > 1 {print $1}')

    # Loop through the list and remove each package
    while snap list | awk 'NR > 1 {print $1}' | grep .; do
        for snap_package in $packages; do
            echo "Removing $snap_package..."
            snap remove "$snap_package" || true
            sleep 2  # Adding a short delay to ensure the package is removed
        done    
    echo "Waiting for Snap packages to be fully removed..."
    sleep 5
    done

    # remove snapd service
    echo "Stopping and disabling snapd service..."
    systemctl stop snapd || true
    systemctl disable snapd || true
    systemctl mask snapd || true
    
    echo "Removing Snapd service..."
    apt-get purge -y snapd || true

    # create preference file to prevent snap to reinstalling itself
    echo "Creating preference file to prevent Snap from being reinstalled..."
    echo "Package: snapd" | tee /etc/apt/preferences.d/nosnap.pref > /dev/null
    echo "Pin: release a=*" | tee -a /etc/apt/preferences.d/nosnap.pref > /dev/null
    echo "Pin-Priority: -10" | tee -a /etc/apt/preferences.d/nosnap.pref > /dev/null

    # remove unwanted folders
    rm -rf ~/snap
    rm -rf /snap
    rm -rf /var/snap
    rm -rf /var/lib/snapd 
}

# install firefox
install_firefox() {
    echo "Adding Mozilla's APT repository and installing Firefox..."
    install -d -m 0755 /etc/apt/keyrings
    wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null
    echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | tee /etc/apt/sources.list.d/mozilla.list > /dev/null
    echo "Package: *" | tee /etc/apt/preferences.d/mozilla > /dev/null
    echo "Pin: origin packages.mozilla.org" | tee -a /etc/apt/preferences.d/mozilla > /dev/null
    echo "Pin-Priority: 1000" | tee -a /etc/apt/preferences.d/mozilla > /dev/null
    apt update && apt install -y firefox
}

remove_snap
install_firefox