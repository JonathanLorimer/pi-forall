{s}: rec
{
  ghcidScript = s "dev" "ghcid --command 'cabal new-repl lib:pi-forall' --allow-eval --warnings";
  allScripts = [ghcidScript];
}
