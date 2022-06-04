# U-Boot: Orange Pi 3 LTS
# Maintainer: Furkan Kardame  <f.kardame@manjaro.org>
# Contributor: Kevin Mihelich <kevin@archlinuxarm.org>
# Contributor: Dragan Simic <dsimic@buserror.io>

pkgname=uboot-orangepi3-lts
pkgver=2022.04
pkgrel=2
_tfaver=2.6
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
        "0001-add-sun50i-h6-orangepi3-lts.patch")
sha256sums=('68e065413926778e276ec3abd28bb32fa82abaa4a6898d570c1f48fbdb08bcd0'
            '4e59f02ccb042d5d18c89c849701b96e6cf4b788709564405354b5d313d173f7'
            '3773d2fd177a5d7b61778480755a26c476354ff882c521dde4b22c8b1e21b4f4')

prepare() {
  cd u-boot-${pkgver/rc/-rc}

  patch -N -p1 -i "${srcdir}/0001-add-sun50i-h6-orangepi3-lts.patch"
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
