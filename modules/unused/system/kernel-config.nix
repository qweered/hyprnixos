{ lib, pkgs, ... }:

let
  # Priority 10 overrides both nixpkgs common-config (default 1000) and CachyOS (mkForce = 50)
  forceAll = lib.mapAttrs (_: lib.mkOverride 10);
in
{
  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-lto-x86_64-v3.extend (
    _: super: {
      kernel = super.kernel.override {
        structuredExtraConfig =
          with lib.kernel;
          forceAll {

            ###################################
            # Explicitly enabled (this system)
            ###################################

            # AMD Ryzen 3 5300U (Renoir/Lucienne)
            KVM = module;
            KVM_AMD = module;
            AMD_IOMMU = yes;
            AMD_PMC = module; # power management controller
            SENSORS_K10TEMP = module; # CPU temperature
            X86_AMD_PLATFORM_DEVICE = yes;
            CRYPTO_DEV_CCP = yes; # AMD Platform Security Processor
            EDAC_MCE_AMD = yes; # memory error detection

            # AMDGPU (Lucienne iGPU)
            DRM_AMDGPU = module;
            DRM_AMD_DC_FP = yes; # display core floating point

            # NVMe (KIOXIA BG5)
            BLK_DEV_LOOP = module; # loop devices, may be needed for mounting ISOs/disk images
            BLK_DEV_NVME = module;
            NVME_CORE = module;

            # Filesystems (XFS root, FAT EFI, FUSE for user mounts, overlay for containers)
            XFS_FS = module;
            FAT_FS = module;
            VFAT_FS = module;
            FUSE_FS = module;
            OVERLAY_FS = module;

            # Realtek RTL8822CE WiFi
            RTW88 = module;
            RTW88_8822CE = module;
            RTW88_PCI = module;
            CFG80211 = module;
            MAC80211 = module;
            RFKILL = module;

            # Realtek USB Bluetooth
            BT = module;
            BT_RTL = module;
            BT_HCIBTUSB = module;

            # Audio: HDA (Realtek ALC236 + HDMI) + AMD ACP/SOF (Renoir)
            SND_HDA_INTEL = module;
            SND_HDA_CODEC_REALTEK = module;
            SND_HDA_CODEC_HDMI = module;
            SOUNDWIRE_AMD = module;

            # USB (xHCI host controller)
            USB_XHCI_HCD = module;

            # Input devices (keyboard, touchpad, multitouch)
            USB_HID = module;
            HID_MULTITOUCH = module;
            I2C_HID = module;
            I2C_PIIX4 = module; # AMD SMBus
            INPUT_EVDEV = module;
            KEYBOARD_ATKBD = module;
            MOUSE_PS2 = module;
            SERIO_I8042 = module;
            INPUT_UINPUT = module; # virtual input for Wayland compositors

            # HP TrueVision HD Camera (UVC USB webcam)
            USB_VIDEO_CLASS = module;
            MEDIA_USB_SUPPORT = yes;

            # Swap compression
            ZRAM = module;

            # HP laptop platform
            HP_WMI = module;

            # TPM (firmware TPM)
            TCG_TPM = module;
            TCG_TIS = module;

            # Watchdog (AMD SP5100)
            SP5100_TCO = module;

            ##############
            # GPU Drivers
            ##############

            DRM_NOUVEAU = no; # NVIDIA (no NVIDIA hardware)
            DRM_RADEON = no; # pre-GCN AMD GPUs (Lucienne uses AMDGPU)
            DRM_I915 = no; # Intel integrated graphics
            DRM_XE = no; # Intel Xe discrete graphics
            DRM_VMWGFX = no; # VMware virtual GPU (guest driver)
            DRM_QXL = no; # QEMU/Spice virtual GPU (guest driver)
            DRM_VIRTIO_GPU = no; # virtio virtual GPU (guest driver)
            DRM_MGAG200 = no; # Matrox server BMC GPU
            DRM_AST = no; # Aspeed server BMC GPU
            DRM_AMDGPU_SI = no; # Southern Islands (GCN 1.0, 2012 era)
            DRM_AMDGPU_CIK = no; # Sea Islands (GCN 2.0, 2013 era)

            ######################
            # WiFi Vendors
            ######################

            WLAN_VENDOR_INTEL = no; # Intel WiFi (iwlwifi)
            WLAN_VENDOR_ATH = no; # Qualcomm Atheros WiFi
            WLAN_VENDOR_BROADCOM = no; # Broadcom WiFi (brcmfmac)
            WLAN_VENDOR_MARVELL = no; # Marvell WiFi (mwifiex)
            WLAN_VENDOR_MEDIATEK = no; # MediaTek WiFi (mt76)
            WLAN_VENDOR_CISCO = no; # Cisco Aironet
            WLAN_VENDOR_ADMTEK = no; # ADMtek USB WiFi
            WLAN_VENDOR_INTERSIL = no; # Intersil Prism
            WLAN_VENDOR_PURELIFI = no; # LiFi (light-based wireless)
            WLAN_VENDOR_RALINK = no; # Ralink USB WiFi
            WLAN_VENDOR_RSI = no; # Redpine Signals
            WLAN_VENDOR_ST = no; # STMicroelectronics WiFi
            WLAN_VENDOR_TI = no; # Texas Instruments WiFi
            WLAN_VENDOR_ZYDAS = no; # ZyDAS USB WiFi
            WLAN_VENDOR_QUANTENNA = no; # Quantenna 802.11ac
            WLAN_VENDOR_SILABS = no; # Silicon Labs WiFi

            ############################
            # Ethernet Vendors
            # (no ethernet port on laptop)
            ############################

            NET_VENDOR_INTEL = no; # Intel e1000/igb/ice
            NET_VENDOR_BROADCOM = no; # Broadcom tg3/bnxt
            NET_VENDOR_MARVELL = no; # Marvell mvneta/sky2
            NET_VENDOR_MELLANOX = no; # Mellanox ConnectX (RDMA/HPC)
            NET_VENDOR_CHELSIO = no; # Chelsio T-series (iSCSI offload)
            NET_VENDOR_CISCO = no; # Cisco VIC (UCS servers)
            NET_VENDOR_QUALCOMM = no; # Qualcomm EMAC
            NET_VENDOR_CAVIUM = no; # Cavium ThunderX
            NET_VENDOR_HUAWEI = no; # HiNIC (Huawei servers)
            NET_VENDOR_PENSANDO = no; # AMD Pensando DSC
            NET_VENDOR_FUNGIBLE = no; # Fungible SmartNIC
            NET_VENDOR_MICROCHIP = no; # Microchip LAN78xx
            NET_VENDOR_MICROSEMI = no; # Microsemi SwitchDev
            NET_VENDOR_SOLARFLARE = no; # Solarflare XtremeScale
            NET_VENDOR_NETRONOME = no; # Netronome Agilio (eBPF SmartNIC)
            NET_VENDOR_EMULEX = no; # Emulex OneConnect
            NET_VENDOR_BROCADE = no; # Brocade CNA
            NET_VENDOR_QLOGIC = no; # QLogic FastLinQ
            NET_VENDOR_MYRICOM = no; # Myricom Myri-10G
            NET_VENDOR_TEHUTI = no; # Tehuti TN40xx 10GbE
            NET_VENDOR_DEC = no; # DEC Tulip (1990s)
            NET_VENDOR_ADAPTEC = no; # Adaptec Starfire
            NET_VENDOR_ALTEON = no; # Alteon Tigon (1990s GbE)
            NET_VENDOR_3COM = no; # 3Com Typhoon/Vortex
            NET_VENDOR_NATSEMI = no; # National Semiconductor dp83820
            NET_VENDOR_AGERE = no; # Agere ET1310
            NET_VENDOR_AMD = no; # AMD PCnet/XGBE
            NET_VENDOR_ATHEROS = no; # Atheros L1/L1E
            NET_VENDOR_REALTEK = no; # Realtek r8169 (no wired ethernet)
            NET_VENDOR_SEEQ = no; # SEEQ 8005
            NET_VENDOR_SIS = no; # SiS 190/191
            NET_VENDOR_SMSC = no; # SMSC LAN911x
            NET_VENDOR_STMICRO = no; # STMicro STMMAC
            NET_VENDOR_VIA = no; # VIA Rhine/Velocity

            # USB ethernet adapters (none used)
            USB_CATC = no; # CATC EL1210A
            USB_KAWETH = no; # KL5KUSB101
            USB_PEGASUS = no; # ADMtek Pegasus
            USB_LAN78XX = no; # Microchip LAN78XX

            # Mobile broadband
            WWAN = no; # WWAN 4G/5G modems

            ########################
            # Network Protocols
            # (enterprise/specialized)
            ########################

            HSR = no; # High-availability Seamless Redundancy (industrial)
            DCB = no; # Data Center Bridging (FCoE/RoCE)
            NET_DSA = no; # Distributed Switch Architecture (embedded switches)
            OPENVSWITCH = no; # Open vSwitch (SDN/hypervisor switching)
            NET_TEAM = no; # link aggregation (bonding alternative)
            BONDING = no; # NIC bonding/teaming (server HA)
            TIPC = no; # Transparent Inter-Process Communication (cluster)
            RDS = no; # Reliable Datagram Sockets (Oracle cluster)
            PHONET = no; # Nokia ISI/Phonet modem protocol
            AF_KCM = no; # Kernel Connection Multiplexor
            MCTP = no; # Management Component Transport (BMC)
            NET_NCSI = no; # Network Controller Sideband (BMC)
            NET_PKTGEN = no; # packet generator (testing)
            NET_DROP_MONITOR = no; # network drop monitoring (debug)
            NET_ACT_IFE = no; # IFE encap action (selects NET_IFE)
            # NET_IFE disabled implicitly via NET_ACT_IFE=no (its only selector)
            MPLS = no; # Multi-Protocol Label Switching (carrier)
            VSOCK = no; # VM sockets (guest driver)

            #######################
            # Unused Subsystems
            #######################

            INFINIBAND = no; # RDMA / InfiniBand (HPC networking)
            HAMRADIO = no; # amateur radio AX.25/ROSE/NetROM
            CAIF = no; # ST-Ericsson CAIF modem protocol
            NFC = no; # Near Field Communication
            CAN_DEV = no; # CAN bus (automotive/industrial)
            ATM = no; # Asynchronous Transfer Mode (legacy WAN)
            FIREWIRE = no; # IEEE 1394 FireWire
            PCMCIA = no; # PC Card / CardBus (legacy laptop expansion)
            PARPORT = no; # parallel port (LPT printers/dongles)
            GAMEPORT = no; # legacy analog joystick port
            ISDN = no; # Integrated Services Digital Network (legacy telephony)
            ATA_OVER_ETH = no; # ATA over Ethernet (cheap SAN alternative)
            MTD = no; # Memory Technology Devices (NOR/NAND flash, embedded)
            MEMSTICK = no; # Sony Memory Stick
            # W1 (Dallas 1-Wire) — can't disable directly, selected by BATTERY_DS2780/2781
            # which are asked AFTER W1 in Kconfig order. Disable the selectors instead.
            BATTERY_DS2780 = no; # Dallas DS2780 battery monitor (selects W1)
            BATTERY_DS2781 = no; # Dallas DS2781 battery monitor (selects W1)
            I3C = no; # I3C bus (next-gen I2C for mobile/IoT sensors)
            MOST = no; # Media Oriented Systems Transport (automotive MOST bus)
            SIOX = no; # Eckelmann SIOX (industrial PLC I/O)
            SLIMBUS = no; # SLIMbus audio (Qualcomm mobile SoCs)
            SPMI = no; # System Power Management Interface (Qualcomm PMICs)
            GNSS = no; # Global Navigation Satellite System (GPS receivers)
            FPGA = no; # Field-Programmable Gate Array manager
            REMOTEPROC = no; # remote processor framework (DSPs on mobile SoCs)
            RPMSG = no; # remote processor messaging (companion to REMOTEPROC)
            AUXDISPLAY = no; # auxiliary displays (HD44780 LCD panels, parport)
            INTERCONNECT = no; # SoC interconnect bus scaling (ARM/Qualcomm NoC)
            COUNTER = no; # counter/encoder subsystem (industrial rotary encoders)
            DEV_DAX = no; # device DAX for persistent memory (NVDIMM)
            POWER_SEQUENCING = no; # power sequencing subsystem (SoC domains)
            PVPANIC = no; # QEMU pvpanic device (guest panic notification)
            VMGENID = no; # virtual machine generation ID (Hyper-V/QEMU)

            #############################
            # Virtualization Guest Drivers
            # (this machine is a KVM host,
            #  not running inside a VM)
            #############################

            XEN = no; # Xen hypervisor paravirt (guest)
            HYPERV = no; # Hyper-V paravirt (guest)
            VIRTIO_PCI = no; # virtio PCI transport (guest)
            VIRTIO_BLK = no; # virtio block device (guest)
            VIRTIO_NET = no; # virtio network (guest)
            VIRTIO_BALLOON = no; # virtio memory ballooning (guest)
            VIRTIO_CONSOLE = no; # virtio serial/console (guest)
            VIRTIO_INPUT = no; # virtio input (guest keyboard/mouse)
            VIRTIO_MMIO = no; # virtio MMIO transport (guest, embedded VMs)
            VIRTIO_MEM = no; # virtio memory hotplug (guest)
            PVH = no; # PVH guest support (Xen PVH entry)
            SCSI_VIRTIO = no; # virtio SCSI (guest)
            VMWARE_PVSCSI = no; # VMware paravirt SCSI (guest)
            CRYPTO_DEV_VIRTIO = no; # virtio crypto offload (guest)

            ######################
            # Platform Drivers
            ######################

            X86_PLATFORM_DRIVERS_DELL = no; # Dell WMI/SMBIOS/BIOS attributes
            SURFACE_PLATFORMS = no; # Microsoft Surface devices
            CHROME_PLATFORMS = no; # Chromebook cros_ec / Wilco

            # Intel-specific platform (not needed on AMD Renoir)
            INTEL_VBTN = no; # Intel Virtual Button (convertible laptop)
            INTEL_RAPL = no; # Intel Running Average Power Limit
            INTEL_MEI = no; # Intel Management Engine Interface
            INTEL_TH = no; # Intel Trace Hub (debug)
            INTEL_TPMI = no; # Intel Topology Aware Register/PM (13th gen+)
            INTEL_IOATDMA = no; # Intel I/OAT DMA (server copy offload)
            INTEL_TCC = no; # Intel Time Coordinated Computing (real-time)
            SPI_INTEL = no; # Intel PCH SPI flash
            DW_DMAC = no; # Synopsys DesignWare DMA (Intel SoCs)
            HSU_DMA = no; # Intel High Speed UART DMA
            PLX_DMA = no; # PLX/Broadcom DMA (PCIe switches)

            # Intel pin control / GPIO (none needed on AMD)
            PINCTRL_INTEL = no; # Intel pinctrl core
            PINCTRL_BAYTRAIL = no; # Atom Z3xxx (2014)
            PINCTRL_BROXTON = no; # Atom/Goldmont (2016)
            PINCTRL_CANNONLAKE = no; # 8th gen Coffee Lake
            PINCTRL_CHERRYVIEW = no; # Atom x5/x7 (2015)
            PINCTRL_DENVERTON = no; # Atom C3xxx (server)
            PINCTRL_ELKHARTLAKE = no; # Atom Elkhart Lake (2020)
            PINCTRL_EMMITSBURG = no; # Xeon Ice Lake-SP (server)
            PINCTRL_GEMINILAKE = no; # Pentium/Celeron J/N (2017)
            PINCTRL_ICELAKE = no; # 10th gen Ice Lake
            PINCTRL_JASPERLAKE = no; # Pentium/Celeron N (2021)
            PINCTRL_LAKEFIELD = no; # Lakefield hybrid (2020)
            PINCTRL_LEWISBURG = no; # Xeon C620 (server)
            PINCTRL_LYNXPOINT = no; # 4th gen Haswell
            PINCTRL_METEORLAKE = no; # 14th gen Meteor Lake
            PINCTRL_SUNRISEPOINT = no; # 6th/7th gen Sky/Kaby Lake
            PINCTRL_TIGERLAKE = no; # 11th gen Tiger Lake
            PINCTRL_ALDERLAKE = no; # 12th gen Alder Lake

            # Intel sound
            SND_SOC_INTEL_AVS = no; # Intel Audio DSP (AVS)
            SND_SOC_SOF_INTEL_TOPLEVEL = no; # Intel SOF toplevel
            SND_SOC_SOF_INTEL_PCI = no; # Intel SOF PCI binding
            SOUNDWIRE_INTEL = no; # Intel SoundWire controller
            SND_SOC_SOF_MERRIFIELD = no; # Intel Merrifield (Atom Z34/Z35)
            SND_SOC_SOF_APOLLOLAKE = no; # Atom Apollo Lake (2016)
            SND_SOC_SOF_GEMINILAKE = no; # Pentium Gemini Lake (2017)
            SND_SOC_SOF_CANNONLAKE = no; # 8th gen Coffee Lake
            SND_SOC_SOF_COFFEELAKE = no; # 8th/9th gen Coffee Lake
            SND_SOC_SOF_ICELAKE = no; # 10th gen Ice Lake
            SND_SOC_SOF_JASPERLAKE = no; # Jasper Lake (2021)
            SND_SOC_SOF_COMETLAKE = no; # 10th gen Comet Lake
            SND_SOC_SOF_TIGERLAKE = no; # 11th gen Tiger Lake
            SND_SOC_SOF_ELKHARTLAKE = no; # Elkhart Lake (2020)
            SND_SOC_SOF_ALDERLAKE = no; # 12th gen Alder Lake
            SND_SOC_SOF_METEORLAKE = no; # 14th gen Meteor Lake
            SND_SOC_SOF_LUNARLAKE = no; # Lunar Lake (2024+)
            SND_SOC_SOF_PANTHERPOINT = no; # 3rd gen Ivy Bridge
            SND_SOC_SOF_BROADWELL = no; # 5th gen Broadwell
            SND_SOC_SOF_BAYTRAIL = no; # Atom Bay Trail (2013)

            # Intel watchdog/hwmon (not useful on AMD)
            I6300ESB_WDT = no; # Intel 6300ESB server watchdog
            IT87_WDT = no; # ITE IT87xx Super I/O watchdog (desktop boards)
            KEMPLD_WDT = no; # Kontron PLD watchdog (industrial PCs)
            SENSORS_IT87 = no; # ITE IT87xx Super I/O hwmon (desktop boards)
            SENSORS_CORETEMP = no; # Intel Core temperature (use k10temp for AMD)

            # Intel crypto (AMD uses CCP instead)
            CRYPTO_DEV_QAT = no; # Intel QuickAssist (server crypto offload)
            CRYPTO_DEV_CHELSIO = no; # Chelsio T6 crypto offload
            CRYPTO_DEV_NITROX = no; # Cavium Nitrox crypto (server)
            CRYPTO_DEV_CCREE = no; # Arm CryptoCell (mobile SoCs)
            CRYPTO_DEV_SAFEXCEL = no; # Inside Secure SafeXcel (embedded)

            #######################
            # Staging / Industrial
            #######################

            STAGING = no; # staging drivers (unfinished, quality varies)

            ######################
            # Media / IR
            ######################

            DVB_CORE = no; # Digital Video Broadcasting (TV tuners)
            MEDIA_ANALOG_TV_SUPPORT = no; # analog TV capture
            MEDIA_DIGITAL_TV_SUPPORT = no; # digital TV capture
            MEDIA_SDR_SUPPORT = no; # Software Defined Radio
            MEDIA_PLATFORM_SUPPORT = no; # SoC camera/ISP (embedded platforms)
            RC_CORE = no; # infrared remote control
            BPF_LIRC_MODE2 = no; # BPF for IR decoding (selects LIRC)
            # LIRC disabled implicitly via RC_CORE=no + BPF_LIRC_MODE2=no (its selectors)
            DRM_DISPLAY_DP_AUX_CEC = no; # DisplayPort AUX CEC (selects CEC_CORE)
            CEC_CH7322 = no; # Chunghwa CEC controller
            CEC_GPIO = no; # GPIO-based CEC
            CEC_SECO = no; # SECO CEC controller
            USB_PULSE8_CEC = no; # Pulse-Eight USB CEC adapter
            USB_RAINSHADOW_CEC = no; # RainShadow Tech USB CEC adapter
            # CEC_CORE disabled implicitly via all selectors above being no

            #######################
            # Unused Filesystems
            #######################

            BTRFS_FS = no; # B-tree copy-on-write filesystem
            F2FS_FS = no; # Flash-Friendly Filesystem (eMMC/UFS)
            # NTFS3_FS — can't disable directly, selected by NTFS_FS (legacy driver).
            NTFS_FS = no; # Legacy NTFS driver (also disables NTFS3_FS it selects)
            GFS2_FS = no; # Global File System 2 (Red Hat cluster)
            OCFS2_FS = no; # Oracle Cluster File System 2
            REISERFS_FS = no; # ReiserFS v3 (legacy)
            JFS_FS = no; # IBM Journaled File System
            NILFS2_FS = no; # NILFS2 log-structured filesystem
            EROFS_FS = no; # Enhanced Read-Only File System (Android)
            BCACHEFS_FS = no; # bcachefs copy-on-write filesystem
            CEPH_FS = no; # Ceph distributed filesystem
            AFS_FS = no; # Andrew File System (Kerberos network FS)
            ORANGEFS_FS = no; # OrangeFS parallel filesystem (HPC)
            CIFS = no; # SMB/CIFS Windows file sharing
            "9P_FS" = no; # Plan 9 filesystem (QEMU host sharing)
            EXT4_FS = no; # ext4 (not used, root is XFS)

            ##################################
            # Storage / Block / Device-Mapper
            ##################################

            NVME_TARGET = no; # NVMe-oF target (export NVMe over network)
            # Fibre Channel (disable selectors then attr)
            SCSI_QLA_FC = no; # QLogic QLA2xxx Fibre Channel
            SCSI_EFCT = no; # Emulex/Broadcom FC target
            SCSI_FC_ATTRS = no; # Fibre Channel transport attributes
            SCSI_LOWLEVEL = no; # low-level SCSI drivers (enterprise HBAs, iSCSI, SAS)
            # NOTE: SCSI_SAS_ATTRS/SCSI_ISCSI_ATTRS are select-ed by drivers asked
            # AFTER them in Kconfig order — disabling them causes infinite loops in
            # generate-config.pl. SCSI_LOWLEVEL=no prevents all their selectors.
            # NOTE: SCSI_ISCSI_ATTRS can't be disabled — force-selected by ISCSI_TCP
            # and enterprise HBA drivers baked into CachyOS defconfig
            SCSI_DEBUG = no; # SCSI debug/test device
            TARGET_CORE = no; # LIO SCSI target (iSCSI/FC target server)
            ISCSI_TARGET = no; # iSCSI target daemon
            BLK_DEV_DRBD = no; # Distributed Replicated Block Device (HA)
            BLK_DEV_NBD = no; # Network Block Device
            BLK_DEV_RBD = no; # Ceph RADOS Block Device
            BLK_DEV_SR = no; # SCSI CD-ROM (no optical drive)
            # CDROM disabled implicitly via BLK_DEV_SR=no (its only selector)
            DM_RAID = no; # device-mapper RAID (also disables BLK_DEV_MD it selects)
            DM_MULTIPATH = no; # device-mapper multipath (SAN failover)
            DM_VDO = no; # device-mapper VDO (dedup + compress, enterprise)
            DM_ERA = no; # device-mapper era (track changed blocks)
            DM_CLONE = no; # device-mapper clone (remote replication)
            DM_CACHE = no; # device-mapper cache (SSD caching for HDD)
            DM_DELAY = no; # device-mapper delay (testing)
            DM_DUST = no; # device-mapper dust (bad sector simulation)
            DM_FLAKEY = no; # device-mapper flakey (fault injection testing)
            DM_LOG_WRITES = no; # device-mapper log writes (FS testing)
            DM_MIRROR = no; # device-mapper mirror (RAID1)
            DM_SNAPSHOT = no; # device-mapper snapshot
            DM_WRITECACHE = no; # device-mapper writecache (SSD write buffer)
            DM_INTEGRITY = no; # device-mapper integrity (checksummed I/O)

            # Enterprise SCSI HBAs (none present in HP laptop)
            SCSI_AACRAID = no; # Adaptec AACRAID
            SCSI_ARCMSR = no; # Areca ARC11xx/12xx/16xx RAID
            SCSI_HPSA = no; # HP Smart Array RAID
            SCSI_LPFC = no; # Emulex LightPulse Fibre Channel
            SCSI_MYRB = no; # Mylex DAC960 RAID (legacy)
            SCSI_MYRS = no; # Mylex DAC960 RAID (new)
            SCSI_PM8001 = no; # PMC-Sierra SPC 8001 SAS/SATA
            SCSI_SMARTPQI = no; # Microsemi SmartPQI RAID
            SCSI_STEX = no; # Promise SuperTrak RAID
            SCSI_UFSHCD = no; # Universal Flash Storage host controller
            SCSI_WD719X = no; # Western Digital WD7193/7197/7296 SCSI

            # Legacy PATA/SATA (this laptop uses NVMe only)
            ATA_PIIX = no; # Intel PIIX/ICH SATA

            ###########################
            # Sound Drivers
            ###########################

            SND_FIREWIRE = no; # FireWire audio interfaces
            SND_PCMCIA = no; # PCMCIA sound cards
            SND_SPI = no; # SPI audio codecs (embedded)
            SND_USB = no; # USB audio (no USB DAC)

            ###########################
            # Input Devices
            ###########################

            INPUT_JOYSTICK = no; # joystick/gamepad drivers
            INPUT_TABLET = no; # Wacom/Aiptek tablets
            INPUT_TOUCHSCREEN = no; # touchscreen drivers (not a touchscreen laptop)
            INPUT_CMA3000 = no; # VTI CMA3000 accelerometer
            INPUT_KXTJ9 = no; # Kionix KXTJ9 accelerometer
            INPUT_IMS_PCU = no; # IMS Passenger Control Unit (kiosk)
            MOUSE_APPLETOUCH = no; # Apple USB trackpad (pre-2015)
            MOUSE_CYAPA = no; # Cypress APA I2C trackpad
            MOUSE_SERIAL = no; # serial mouse (legacy RS-232)

            # I2C adapters (not present on AMD Renoir)
            I2C_NFORCE2 = no; # nForce2/CK804/MCP (old NVIDIA chipset)
            I2C_SCMI = no; # SMBus ACPI CMI (via EC)
            I2C_VIAPRO = no; # VIA VT82C596/686 SMBus

            ########################
            # USB Controllers
            # (only xHCI needed)
            ########################

            USB_DWC2 = no; # Synopsys DesignWare USB2 (embedded/SoC)
            USB_DWC3 = no; # Synopsys DesignWare USB3 (embedded/SoC)
            USB_CHIPIDEA = no; # ChipIdea USB (NXP i.MX SoCs)
            USB_GADGET = no; # USB device/gadget mode (act as USB device)
            USB_PRINTER = no; # USB printer class driver
            USB_SERIAL = no; # USB-to-serial converters
            # USB_ACM — can't disable directly, selected by USB_VL600 (asked after it).
            # Disable USB_NET_DRIVERS to kill all USB net drivers including VL600.
            USB_NET_DRIVERS = no; # USB network adapter drivers (no USB ethernet/LTE)

            ########################
            # Misc
            ########################

            COMEDI = no; # data acquisition boards (lab instruments)
            GREYBUS = no; # Google Project Ara modular phone bus
            ACCESSIBILITY = no; # speakup/braille console drivers
            ANDROID = no; # Android binder IPC (containers like Waydroid)
            VMD = no; # Intel Volume Management Device (PCIe NVMe domain)
            IIO = no; # Industrial I/O subsystem (accelerometers, ADCs, gyros)
            PSTORE_BLK = no; # pstore block device backend (ramoops alternative)
            PSTORE_RAM = no; # pstore RAM backend (crash log in reserved RAM)
            DM_VERITY = no; # device-mapper verity (read-only integrity, ChromeOS/Android)

            ########################################
            # Round 2: Aggressive disables
            ########################################

            # ── Parent gates (each kills dozens of drivers) ──

            ATA_SFF = no; # kills ALL legacy PATA/SFF SATA controllers (~41 drivers)
            USB_GSPCA = no; # kills all GSPCA legacy webcam drivers (~47 drivers, UVC is separate)
            FB_TFT = no; # kills all SPI TFT display drivers (~32 drivers)
            V4L_PLATFORM_DRIVERS = no; # kills SoC camera/ISP V4L2 drivers (UVC unaffected)
            V4L_MEM2MEM_DRIVERS = no; # video codec mem2mem engines (SoC only)
            V4L_TEST_DRIVERS = no; # V4L2 test/virtual drivers
            TYPEC = no; # USB Type-C subsystem (no Type-C ports on this laptop)
            QRTR = no; # Qualcomm IPC Router (not a Qualcomm platform)

            # ── Intel (AMD Ryzen system — no Intel hardware) ──

            KVM_INTEL = no; # Intel VMX (using KVM_AMD)
            PERF_EVENTS_INTEL_UNCORE = no; # Intel uncore perf counters
            PERF_EVENTS_INTEL_RAPL = no; # Intel RAPL energy perf
            PERF_EVENTS_INTEL_CSTATE = no; # Intel C-state perf
            BT_INTEL = no; # Intel Bluetooth firmware
            BT_INTEL_PCIE = no; # Intel Bluetooth PCIe
            INTEL_TDX_GUEST = no; # Intel TDX confidential computing (guest)
            X86_INTEL_LPSS = no; # Intel Low Power Subsystem (UART/SPI/I2C on Intel SoCs)
            SND_SOC_INTEL_CATPT = no; # Intel Haswell/Broadwell audio DSP
            SND_SOC_ACPI_INTEL_MATCH = no; # Intel SoC ACPI audio matching

            # ── NVIDIA remnants (no NVIDIA hardware) ──

            I2C_NVIDIA_GPU = no; # NVIDIA GPU I2C adapter
            NET_VENDOR_NVIDIA = no; # NVIDIA nForce ethernet
            HID_NVIDIA_SHIELD = no; # NVIDIA Shield controller
            NVIDIA_WMI_EC_BACKLIGHT = no; # NVIDIA WMI EC backlight

            # ── HDA codecs (only Realtek ALC + ATI HDMI needed) ──

            SND_HDA_CODEC_ANALOG = no; # Analog Devices HDA
            SND_HDA_CODEC_SIGMATEL = no; # SigmaTel HDA
            SND_HDA_CODEC_VIA = no; # VIA HDA
            SND_HDA_CODEC_CONEXANT = no; # Conexant HDA
            SND_HDA_CODEC_SENARYTECH = no; # SenaryTech HDA
            SND_HDA_CODEC_CA0110 = no; # Creative CA0110
            SND_HDA_CODEC_CA0132 = no; # Creative CA0132
            SND_HDA_CODEC_CMEDIA = no; # C-Media HDA
            SND_HDA_CODEC_CM9825 = no; # C-Media CM9825
            SND_HDA_CODEC_SI3054 = no; # Silicon Labs Si3054 modem
            SND_HDA_CODEC_CIRRUS = no; # Cirrus Logic HDA
            SND_HDA_CODEC_CS420X = no; # Cirrus CS4206/4207
            SND_HDA_CODEC_CS421X = no; # Cirrus CS4210/4213
            SND_HDA_CODEC_CS8409 = no; # Cirrus CS8409
            SND_HDA_CODEC_HDMI_INTEL = no; # Intel HDMI/DP audio
            SND_HDA_CODEC_HDMI_NVIDIA = no; # NVIDIA HDMI audio
            SND_HDA_CODEC_HDMI_NVIDIA_MCP = no; # NVIDIA MCP HDMI audio
            SND_HDA_CODEC_HDMI_TEGRA = no; # NVIDIA Tegra HDMI audio

            # ── Legacy framebuffer drivers (DRM/simpledrm used) ──

            FB_CIRRUS = no; # Cirrus Logic GD5446
            FB_PM2 = no; # Permedia2
            FB_CYBER2000 = no; # CyberPro 2000/2010/5000
            FB_ARC = no; # Arc Monochrome
            FB_VGA16 = no; # VGA 16-color
            FB_UVESA = no; # Userspace VESA
            FB_N411 = no; # N411 e-paper
            FB_HGA = no; # Hercules mono
            FB_OPENCORES = no; # OpenCores VGA
            FB_S1D13XXX = no; # Epson S1D13xxx
            FB_NVIDIA = no; # NVIDIA legacy fbdev
            FB_RIVA = no; # NVIDIA Riva legacy fbdev
            FB_I740 = no; # Intel i740
            FB_RADEON = no; # ATI Radeon legacy fbdev
            FB_ATY128 = no; # ATI Rage 128
            FB_ATY = no; # ATI Mach64
            FB_HECUBA = no; # Hecuba e-paper

            # ── HID drivers (only generic + multitouch needed) ──

            HID_A4TECH = no;
            HID_ACCUTOUCH = no;
            HID_ACRUX = no;
            HID_ALPS = no;
            HID_APPLE = no;
            HID_APPLEIR = no;
            HID_ASUS = no;
            HID_AUREAL = no;
            HID_BELKIN = no;
            HID_BETOP = no;
            HID_CHERRY = no;
            HID_CHICONY = no;
            HID_CMEDIA = no;
            HID_CORSAIR = no;
            HID_COUGAR = no;
            HID_CREATIVE_SB0540 = no;
            HID_CYPRESS = no;
            HID_DRAGONRISE = no;
            HID_ELAN = no;
            HID_ELECOM = no;
            HID_ELO = no;
            HID_EMS_FF = no;
            HID_EZKEY = no;
            HID_FT260 = no;
            HID_GEMBIRD = no;
            HID_GFRM = no;
            HID_GLORIOUS = no;
            HID_GOOGLE_HAMMER = no;
            HID_GREENASIA = no;
            HID_GYRATION = no;
            HID_HOLTEK = no;
            HID_HYPERV = no;
            HID_ICADE = no;
            HID_ITE = no;
            HID_JABRA = no;
            HID_KENSINGTON = no;
            HID_KEYTOUCH = no;
            HID_KYE = no;
            HID_LCPOWER = no;
            HID_LENOVO = no;
            HID_LETSKETCH = no;
            HID_LOGITECH = no;
            HID_MAGICMOUSE = no;
            HID_MALTRON = no;
            HID_MAYFLASH = no;
            HID_MCP2221 = no;
            HID_MEGAWORLD = no;
            HID_MICROSOFT = no;
            HID_MONTEREY = no;
            HID_NTI = no;
            HID_NTRIG = no;
            HID_ORTEK = no;
            HID_PENMOUNT = no;
            HID_PETALYNX = no;
            HID_PICOLCD = no;
            HID_PLANTRONICS = no;
            HID_PLAYSTATION = no;
            HID_PRIMAX = no;
            HID_PRODIKEYS = no;
            HID_RAZER = no;
            HID_REDRAGON = no;
            HID_RETRODE = no;
            HID_RMI = no;
            HID_ROCCAT = no;
            HID_SAITEK = no;
            HID_SAMSUNG = no;
            HID_SMARTJOYPLUS = no;
            HID_SONY = no;
            HID_SPEEDLINK = no;
            HID_STEAM = no;
            HID_STEELSERIES = no;
            HID_SUNPLUS = no;
            HID_THRUSTMASTER = no;
            HID_TIVO = no;
            HID_TOPEES = no;
            HID_TOPSEED = no;
            HID_TWINHAN = no;
            HID_UCLOGIC = no;
            HID_UDRAW_PS3 = no;
            HID_VIEWSONIC = no;
            HID_WALTOP = no;
            HID_XIAOMI = no;
            HID_XINMO = no;
            HID_ZEROPLUS = no;
            HID_ZYDACRON = no;
            HID_SENSOR_HUB = no;
            HID_WACOM = no;

            # ── Keyboard drivers (only ATKBD needed) ──

            KEYBOARD_ADC = no;
            KEYBOARD_ADP5520 = no;
            KEYBOARD_ADP5585 = no;
            KEYBOARD_ADP5588 = no;
            KEYBOARD_APPLESPI = no;
            KEYBOARD_QT1050 = no;
            KEYBOARD_QT1070 = no;
            KEYBOARD_QT2160 = no;
            KEYBOARD_DLINK_DIR685 = no;
            KEYBOARD_LKKBD = no;
            KEYBOARD_GPIO = no;
            KEYBOARD_GPIO_POLLED = no;
            KEYBOARD_TCA8418 = no;
            KEYBOARD_MATRIX = no;
            KEYBOARD_LM8323 = no;
            KEYBOARD_LM8333 = no;
            KEYBOARD_MAX7359 = no;
            KEYBOARD_MAX7360 = no;
            KEYBOARD_MPR121 = no;
            KEYBOARD_NEWTON = no;
            KEYBOARD_OPENCORES = no;
            KEYBOARD_PINEPHONE = no;
            KEYBOARD_SAMSUNG = no;
            KEYBOARD_STOWAWAY = no;
            KEYBOARD_SUNKBD = no;
            KEYBOARD_STMPE = no;
            KEYBOARD_IQS62X = no;
            KEYBOARD_OMAP4 = no;
            KEYBOARD_TM2_TOUCHKEY = no;

            # ── Watchdog drivers (only SP5100_TCO needed) ──

            WDAT_WDT = no; # ACPI WDAT watchdog
            ALIM7101_WDT = no;
            ADVANTECH_WDT = no;
            ADVANTECH_EC_WDT = no;
            SOFTDOG = no; # software watchdog
            ACQUIRE_WDT = no;
            EUROTECH_WDT = no;
            IB700_WDT = no;
            IBMASR = no;
            WAFER_WDT = no;
            SBC_FITPC2_WDT = no;
            SBC7240_WDT = no;
            NI903X_WDT = no;
            NIC7018_WDT = no;
            MEN_A21_WDT = no;
            XEN_WDT = no;
            PCWD_PCI = no;
            ZIIRAVE_WDT = no;

            # ── Battery/charger IC drivers (ACPI battery only, no embedded ICs) ──

            BATTERY_DS2760 = no;
            BATTERY_DS2782 = no;
            BATTERY_SBS = no;
            CHARGER_SBS = no;
            BATTERY_BQ27XXX = no;
            BATTERY_MAX17040 = no;
            BATTERY_MAX17042 = no;
            CHARGER_MAX8903 = no;
            CHARGER_LP8727 = no;
            CHARGER_BQ2415X = no;
            CHARGER_BQ24190 = no;
            CHARGER_BQ24257 = no;
            CHARGER_BQ24735 = no;
            CHARGER_BQ25890 = no;
            CHARGER_BQ256XX = no;
            CHARGER_SMB347 = no;
            CHARGER_ADP5061 = no;
            BATTERY_CW2015 = no;
            BATTERY_GOLDFISH = no;
            CHARGER_GPIO = no;
            CHARGER_MANAGER = no;

            # ── Misc additional ──

            MAC_HID = no; # Apple HID-to-input emulation
            GOOGLE_FRAMEBUFFER_COREBOOT = no; # Google coreboot framebuffer
            LATTICE_ECP3_CONFIG = no; # Lattice ECP3 FPGA
            SND_SOC_USB = no; # USB SoC audio
            MEDIA_TEST_SUPPORT = no; # media test drivers
            CRYPTO_BENCHMARK = no; # crypto speed benchmark
            SND_RAWMIDI = no; # MIDI interface (no MIDI hardware)
            MOUSE_BCM5974 = no; # Apple BCM5974 trackpad
            MOUSE_ELAN_I2C = no; # Elantech I2C touchpad
            RTC_DRV_NVIDIA_VRS10 = no; # NVIDIA VRS10 RTC
          };
      };
    }
  );
}
