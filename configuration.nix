# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  #  boot.loader.systemd-boot.enable = true;
  #  boot.loader.efi.canTouchEfiVariables = true;

  # networking.hostName = "nixos"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  # time.timeZone = "Europe/Amsterdam";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkbOptions in tty.
  # };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;




  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = {
  #   "eurosign:e";
  #   "caps:escape" # map caps to escape.
  # };

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.users.jane = {
  #   isNormalUser = true;
  #   extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  #   packages = with pkgs; [
  #     firefox
  #     thunderbird
  #   ];
  # };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  # environment.systemPackages = with pkgs; [
  #   vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #   wget
  # ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  #  system.stateVersion = "22.05"; # Did you read the comment?

  #}

  #boot loader
  boot.loader = {
    grub = {
      enable = true;
      #  version = 2;
      device = "nodev";
      efiSupport = true;
    };
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };
  };

  # networking
  networking = {
    networkmanager.enable = true;
    hostName = "nix_box";
  };

  # QEMU-specific
  services.spice-vdagentd.enable = true;
  services.qemuGuest.enable = true;

  # locales
  # https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
  #time.timeZone = "America/New_York";
  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_GB.UTF-8";

  # graphics
  services.xserver = {
    enable = true;
    # setup the resolution to match your screen
    resolutions = [{ x = 1920; y = 1080; }];
    virtualScreen = { x = 1920; y = 1080; };
    layout = "gb"; # keyboard layout
    desktopManager = {
      xterm.enable = false;
      #xfce.enable = true;
      gnome.enable = true;
      # plasma5.enable = true;
    };
    displayManager.gdm.enable = true;
    #displayManager.defaultSession = "gnome";
    autorun = true; # run on graphic interface startup
    libinput.enable = true; # touchpad support
  };

  # audio
  sound.enable = true;
  nixpkgs.config.pulseaudio = true;
  hardware.pulseaudio.enable = true;

  users.users = {
    nixie = {
      # change this to you liking
      createHome = true;
      isNormalUser = true;
      extraGroups = [
        "wheel"
      ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINlTcGPRAUMlP8wzJo9x8iWhOHnXQvHOmWOgD+4yva30 yt@yt-blade"
      ];
    };
    root = {
      extraGroups = [
        "wheel"
      ];
    };
  };

  services.openssh.settings = {
    enable = true;
    kexAlgorithms = [ "curve25519-sha256" ];
    ciphers = [ "chacha20-poly1305@openssh.com" ];
    passwordAuthentication = true;
    permitRootLogin = "yes"; # do not allow to login as root user
    kbdInteractiveAuthentication = false;
  };

  # workaround to make plasma5 and gnome compatible
  # programs.ssh.askPassword = pkgs.lib.mkForce "${pkgs.gnome.seahorse.out}/libexec/seahorse/ssh-askpass";

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    # cli utils
    git
    curl
    wget
    neovim
    htop
    btop
    ripgrep
    fd
    bat
    yadm
    zsh
    wezterm
    kitty
    tealdeer
    distrobox
    file
    zig
    gcc
    gcc
    exa
    zstd
    rclone
    nodePackages.typescript
    gnumake
    zoxide
    python3
    moreutils
    edir
    ranger
    nnn
    neofetch
    fzf
    duf
    topgrade
    ncdu
    glib
    glib.dev
    hydra-check
    gh
    zellij

    # browser
    #firefox

    (vscode-with-extensions.override {
      vscodeExtensions = with vscode-extensions; [
        bbenoist.nix # syntax highlight for .nix files in vscode
      ];
    })
  ];

  programs.firefox.enable = true;

  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" "FantasqueSansMono" ]; })
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    liberation_ttf
    mplus-outline-fonts.githubRelease
    dina-font
    proggyfonts
  ];

  nix.settings.auto-optimise-store = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  fonts.fontDir.enable = true;
  services.flatpak.enable = true;
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
  environment.shells = with pkgs; [ zsh ];
  programs.neovim.enable = true;
  programs.neovim.defaultEditor = true;
  environment.variables.EDITOR = "nvim";
  environment.variables.SUDO_EDITOR = "nvim";



  system.stateVersion = "23.05"; # Did you read the comment?

}

