# U-Boot: Orange Pi 3 LTS
# Maintainer: Furkan Kardame  <f.kardame@manjaro.org>
# Contributor: Kevin Mihelich <kevin@archlinuxarm.org>
# Contributor: Dragan Simic <dsimic@buserror.io>

pkgname=uboot-orangepi3-lts
pkgver=2022.04
pkgrel=1
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
        "0002-add-sun50i-h6-orangepi3-lts.patch")
md5sums=('a5a70f6c723d2601da7ea93ae95642f9'
         'abb0e05dd2e719f094841790c81efa57'
         '5519ebbfa6829d8b5a81350da2848e0d'
         'ebbdf37b1079ddfb279d1193569bfe1e')

prepare() {
  # This is temporary and will be no longer needed with newer TF-A
  cd trusted-firmware-a-${_tfaver}
  patch -N -p1 -i "${srcdir}/0001-Disable-stack-protection-explicitly.patch"

  cd ../u-boot-${pkgver/rc/-rc}
  patch -N -p1 -i "${srcdir}/0002-add-sun50i-h6-orangepi3-lts.patch"
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
  # Allwinner provides no plat_get_stack_protector_canary() hook,
  # so explicitly disable stack protection checks in GCC; this is
  # temporary and will be no longer needed with newer TF-A
  make PLAT=sun50i_h6 ENABLE_STACK_PROTECTOR=none bl31
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
