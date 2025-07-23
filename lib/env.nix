{ lib }:
{
  requireEnvVar =
    varName:
    let
      value = builtins.getEnv varName;
    in
    lib.throwIf (value == "") "${varName} environment variable is not set" value;
}
