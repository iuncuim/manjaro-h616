# U-Boot: Orange Pi Zero 3
# Maintainer: Furkan Kardame  <f.kardame@manjaro.org>
# Contributor: Mikhail Kalashnikov <iuncuim@gmail.com>

pkgname=uboot-h616
pkgver=v2023.10
pkgrel=1
_tfaver=v2.9.0
pkgdesc="U-Boot for h616 devices"
arch=('aarch64')
url='http://www.denx.de/wiki/U-Boot/WebHome'
license=('GPL')
makedepends=('bc' 'python' 'python-setuptools' 'swig' 'dtc' 'arm-none-eabi-gcc' 'bison' 'flex')
provides=('uboot')
conflicts=('uboot')
replaces=('uboot-h616')
install=${pkgname}.install
source=("https://source.denx.de/u-boot/u-boot/-/archive/${pkgver}/u-boot-${pkgver}.tar.gz"
        "https://git.trustedfirmware.org/TF-A/trusted-firmware-a.git/snapshot/trusted-firmware-a-${_tfaver}.tar.gz"
        "0001-mctl_phy_configure_odt.patch"
        "0002-sunxi-H616-add-LPDDR4-DRAM-support.patch"
        "0003-Update-pmic_bus.c-board.c-and-6-more-files.patch"
        "0004-sunxi-H616-GPU-enable-hack.patch"
        "0005-sunxi-add-barrier-in-memory-check.patch"
        )
sha256sums=('61a2f1b304e014e5caf1f61f0701eac2911ffb3fd20084528b2dfc8f0b8a706a'
            '510207a4ecc263bace34213ccd5dc1b8ce22945cd55d2452fef4af6d76e0d41e'
            '25dc057592768fb2d63f4010c4c08a36a226b7deb9639c517c42cd37d824f7d9'
            '7eff10927f91f1d07601aeb4e198255ddaca4bb7fc76309d8d0835791cf90662'
            '4178ac743e84c296465c8cd9a45a4b4c3ce7dcf691a4e09606baeae1fcf94199'
            '10aac0b0125ae73de7af36716aa55e28c35a1c1cc100bbd59e8fa695c5fc21a7'
            'SKIP'
            )

prepare() {
  apply_patches() {
      local PATCH
      for PATCH in "${source[@]}"; do
          PATCH="${PATCH%%::*}"
          PATCH="${PATCH##*/}"
          [[ ${PATCH} = *.patch ]] || continue
          msg2 "Applying patch: ${PATCH}..."
          patch -N -p1 < "../${PATCH}"
      done
  }

  cd u-boot-${pkgver}
  apply_patches
}

build() {
  # Avoid build warnings by editing a .config option in place instead of
  # appending an option to .config, if an option is already present
  update_config() {
    if ! grep -q "^$1=$2$" .config; then
      if grep -q "^# $1 is not set$" .config; then
        sed -i -e "s/^# $1 is not set$/$1=$2/g" .config
      elif grep -q "^$1=" .config; then
        sed -i -e "s/^$1=.*/$1=$2/g" .config
      else
        echo "$1=$2" >> .config
      fi
    fi
  }

  unset CFLAGS CXXFLAGS CPPFLAGS LDFLAGS

  cd trusted-firmware-a-${_tfaver}

  echo -e "\nBuilding TF-A for H616 devices...\n"
  # Not performing regulator setup in TF-A allows Linux to boot on
  # this board correctly, which otherwise fails because the Ethernet
  # PHY requires a coordinated bringup of two regulators
  make PLAT=sun50i_h616 SUNXI_SETUP_REGULATORS=0 bl31
  cp build/sun50i_h616/release/bl31.bin ../u-boot-${pkgver}

  cd ../u-boot-${pkgver}

  echo -e "\nBuilding U-Boot for OrangePi Zero 3...\n"
  make orangepi_zero3_defconfig

  update_config 'CONFIG_IDENT_STRING' '" Manjaro Linux ARM"'
  update_config 'CONFIG_OF_LIBFDT_OVERLAY' 'y'

  make EXTRAVERSION=-${pkgrel}
  cp u-boot-sunxi-with-spl.bin u-boot-sunxi-with-spl-opi-zero3.bin
}

package() {
  cd u-boot-${pkgver}

  mkdir -p "${pkgdir}/boot/extlinux"
  install -D -m 0644 u-boot-sunxi-with-spl-opi-zero3.bin -t "${pkgdir}/boot"
}
