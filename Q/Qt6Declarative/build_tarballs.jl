# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

name = "Qt6Declarative"
version = v"6.0.3"

# Collection of sources required to build qt6
sources = [
    ArchiveSource("https://download.qt.io/official_releases/qt/$(version.major).$(version.minor)/$version/submodules/qtdeclarative-everywhere-src-$version.tar.xz",
                  "f2987fb4c698c5930bbb58e75f7c3de16592f2e79696ed348d77556743db30bd"),
]

script = raw"""
export LD_LIBRARY_PATH=$host_libdir:$LD_LIBRARY_PATH

cd $WORKSPACE/srcdir
mkdir build
cd build/

qtsrcdir=`ls -d ../qtdeclarative-*`

qt-configure-module $qtsrcdir
cmake --build . --parallel ${nproc}
cmake --install .

install_license $qtsrcdir/LICENSE.LGPL3
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = expand_cxxstring_abis(filter(!Sys.isapple, supported_platforms()))
platforms_macos = [ Platform("x86_64", "macos") ]

# The products that we will ensure are always built
products = [
    LibraryProduct(["Qt6Qml", "libQt6Qml", "QtQml"], :libqt6qml),
    LibraryProduct(["Qt6QmlModels", "libQt6QmlModels", "QtQmlModels"], :libqt6qmlmodels),
    LibraryProduct(["Qt6QmlWorkerScript", "libQt6QmlWorkerScript", "QtQmlWorkerScript"], :libqt6qmlworkerscript),
    LibraryProduct(["Qt6Quick", "libQt6Quick", "QtQuick"], :libqt6quick),
    LibraryProduct(["Qt6QuickParticles", "libQt6QuickParticles", "QtQuickParticles"], :libqt6quickparticles),
    LibraryProduct(["Qt6QuickShapes", "libQt6QuickShapes", "QtQuickShapes"], :libqt6quickshapes),
    LibraryProduct(["Qt6QuickTest", "libQt6QuickTest", "QtQuickTest"], :libqt6quicktest),
    LibraryProduct(["Qt6QuickWidgets", "libQt6QuickWidgets", "QtQuickWidgets"], :libqt6quickwidgets),
]

products_macos = [
    FrameworkProduct("QtQml", :libqt6qml),
    FrameworkProduct("QtQmlModels", :libqt6qmlmodels),
    FrameworkProduct("QtQmlWorkerScript", :libqt6qmlworkerscript),
    FrameworkProduct("QtQuick", :libqt6quick),
    FrameworkProduct("QtQuickParticles", :libqt6quickparticles),
    FrameworkProduct("QtQuickShapes", :libqt6quickshapes),
    FrameworkProduct("QtQuickTest", :libqt6quicktest),
    FrameworkProduct("QtQuickWidgets", :libqt6quickwidgets),
]

# Dependencies that must be installed before this package can be built
dependencies = [
    HostBuildDependency("Qt6Base_jll"),
    Dependency("Qt6Base_jll"),
]

include("../../fancy_toys.jl")

if any(should_build_platform.(triplet.(platforms_macos)))
    build_tarballs(ARGS, name, version, sources, script, platforms_macos, products_macos, dependencies; preferred_gcc_version = v"8", julia_compat="1.6")
end
if any(should_build_platform.(triplet.(platforms)))
    build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies; preferred_gcc_version = v"8", julia_compat="1.6")
end
