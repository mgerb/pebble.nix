{
  stdenv,
  lib,
  fetchzip,
  autoPatchelfHook,

  expat,
  ncurses5,
  python2,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pebble-toolchain-bin";
  version = "4.5";

  src =
    (rec {
      x86_64-linux = fetchzip {
        url = "https://sdk.core.store/releases/4.5/sdk-core.tar.gz";
        hash = "sha256-nrR0nFd4S73rCiVwEEBbN+WuelyqPAsCyFY5D5sU8SU=";
      };
      x86_64-darwin = fetchzip {
        url = "https://sdk.core.store/releases/4.5/sdk-core.tar.gz";
        hash = "sha256-nrR0nFd4S73rCiVwEEBbN+WuelyqPAsCyFY5D5sU8SU=";
      };
      aarch64-darwin = x86_64-darwin;
    }).${stdenv.hostPlatform.system};

  nativeBuildInputs = lib.optional stdenv.hostPlatform.isLinux autoPatchelfHook;
  buildInputs =
    [ python2 ]
    ++ (lib.optionals stdenv.hostPlatform.isLinux [
      expat
      ncurses5
      python2
      zlib
    ]);

  installPhase = ''
    mv arm-cs-tools $out
  '';

  fixupPhase = lib.optionalString stdenv.hostPlatform.isDarwin ''
    # TODO: this doesn't work on apple silicon. figure out how to conjure an x86_64 python2 on there
    install_name_tool -change /System/Library/Frameworks/Python.framework/Versions/2.7/Python ${python2}/lib/libpython2.7.dylib $out/bin/arm-none-eabi-gdb
  '';
})
