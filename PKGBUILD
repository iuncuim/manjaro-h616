# U-Boot: Orange Pi 3 LTS
# Maintainer: Furkan Kardame  <f.kardame@manjaro.org>
# Contributor: Kevin Mihelich <kevin@archlinuxarm.org>
# Contributor: Dragan Simic <dsimic@buserror.io>

pkgname=uboot-orangepi3-lts
pkgver=2022.04
pkgrel=6
_tfaver=2.2
pkgdesc="U-Boot for Orange Pi 3 LTS"
arch=('aarch64')
url='http://www.denx.de/wiki/U-Boot/WebHome'
license=('GPL')
makedepends=('bc' 'python' 'python-setuptools' 'swig' 'dtc' 'arm-none-eabi-gcc' 'bison' 'flex')
provides=('uboot')
conflicts=('uboot')
replaces=('uboot-opi3-lts')
install=${pkgname}.install
source=("ftp://ftp.denx.de/pub/u-boot/u-boot-${pkgver/rc/-rc}.tar.bz2"
        "https://git.trustedfirmware.org/TF-A/trusted-firmware-a.git/snapshot/trusted-firmware-a-${_tfaver}.tar.gz"
        "0001-Disable-stack-protection-explicitly.patch"
        "0002-add-sun50i-h6-orangepi3-lts.patch"
        "0003-board-sunxi-fix-h6-led.patch")
sha256sums=('68e065413926778e276ec3abd28bb32fa82abaa4a6898d570c1f48fbdb08bcd0'
            '01d9190755f752929c82bdf6b0e16868dc7a818666b84e1dbdfa4726f6bb2731'
            '3205c5270361620235a6af82e350cb312e44943bdf77662fde3365f22a191381'
            'c0e897741475c23a4c902d0a1fc2ed69b0e4b8c4258fe06400314a8e06cd513a'
            '08901931c4ef0613964ba1e027e6b3bc7c76d4e14b4a7c5928bee54e8404143b')

prepare() {
  # This is temporary and will be no longer needed with newer TF-A
  cd trusted-firmware-a-${_tfaver}
  patch -N -p1 -i "${srcdir}/0001-Disable-stack-protection-explicitly.patch"

  cd ../u-boot-${pkgver/rc/-rc}
  patch -N -p1 -i "${srcdir}/0002-add-sun50i-h6-orangepi3-lts.patch"
  patch -N -p1 -i "${srcdir}/0003-board-sunxi-fix-h6-led.patch"
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

  echo -e "\nBuilding TF-A for Orange Pi 3 LTS...\n"
  # Not performing regulator setup in TF-A allows Linux to boot on
  # this board correctly, which otherwise fails because the Ethernet
  # PHY requires a coordinated bringup of two regulators
  make PLAT=sun50i_h6 SUNXI_SETUP_REGULATORS=0 bl31
  cp build/sun50i_h6/release/bl31.bin ../u-boot-${pkgver/rc/-rc}

  cd ../u-boot-${pkgver/rc/-rc}

  echo -e "\nBuilding U-Boot for Orange Pi 3 LTS...\n"
  make orangepi_3_lts_defconfig

  update_config 'CONFIG_IDENT_STRING' '" Manjaro Linux ARM"'
  update_config 'CONFIG_OF_LIBFDT_OVERLAY' 'y'

  make EXTRAVERSION=-${pkgrel}
  cp u-boot-sunxi-with-spl.bin u-boot-sunxi-with-spl-orangepi3-lts.bin
}

package() {
  cd u-boot-${pkgver/rc/-rc}

  mkdir -p "${pkgdir}/boot/extlinux"
  install -D -m 0644 u-boot-sunxi-with-spl-orangepi3-lts.bin -t "${pkgdir}/boot"
}
