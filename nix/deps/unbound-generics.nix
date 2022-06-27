{
  mkDerivation,
  ansi-wl-pprint,
  base,
  containers,
  contravariant,
  criterion,
  deepseq,
  exceptions,
  fetchgit,
  lib,
  mtl,
  profunctors,
  QuickCheck,
  tasty,
  tasty-hunit,
  tasty-quickcheck,
  template-haskell,
  transformers,
  transformers-compat,
}:
mkDerivation {
  pname = "unbound-generics";
  version = "0.4.1";
  src = fetchgit {
    url = "https://github.com/lambdageek/unbound-generics";
    sha256 = "0jq6pcaj6fvq9sy5i8lmi6kbdykp7c28slk1nw5xfn5jzb2ppvgz";
    rev = "04f940740d95aecd105fd87ed9f49ee0b81da408";
    fetchSubmodules = true;
  };
  libraryHaskellDepends = [
    ansi-wl-pprint
    base
    containers
    contravariant
    deepseq
    exceptions
    mtl
    profunctors
    template-haskell
    transformers
    transformers-compat
  ];
  testHaskellDepends = [
    base
    mtl
    QuickCheck
    tasty
    tasty-hunit
    tasty-quickcheck
  ];
  benchmarkHaskellDepends = [base criterion deepseq];
  homepage = "http://github.com/lambdageek/unbound-generics";
  description = "Support for programming with names and binders using GHC Generics";
  license = lib.licenses.bsd3;
}
