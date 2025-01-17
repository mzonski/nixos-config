{ self, lib, ... }:

let
  inherit (builtins)
    attrValues
    readDir
    pathExists
    concatLists
    ;
  inherit (lib)
    id
    mapAttrsToList
    filterAttrs
    hasPrefix
    hasSuffix
    nameValuePair
    removeSuffix
    foldl'
    ;
  inherit (self.attrs) mapFilterAttrs;

  filterIgnored = name: type: type != null && !(hasPrefix "_" name);
  filterIgnoredDirectories = name: type: type == "directory" && !(hasPrefix "_" name);
  isNixDirModule = type: path: type == "directory" && pathExists "${path}/default.nix";
  isRegularModule = type: name: type == "regular" && name != "default.nix" && hasSuffix ".nix" name;
in
rec {
  mapModules =
    dir: fn:
    mapFilterAttrs filterIgnored (
      name: type:
      let
        path = "${toString dir}/${name}";
      in
      if isNixDirModule type path then
        nameValuePair name (fn path)
      else if isRegularModule type name then
        nameValuePair (removeSuffix ".nix" name) (fn path)
      else
        nameValuePair "" null
    ) (readDir dir);

  mapModules' = dir: fn: attrValues (mapModules dir fn);

  mapModulesRec =
    dir: fn:
    mapFilterAttrs filterIgnored (
      name: type:
      let
        path = "${toString dir}/${name}";
      in
      if type == "directory" then
        nameValuePair name (mapModulesRec path fn)
      else if isRegularModule type name then
        nameValuePair (removeSuffix ".nix" name) (fn path)
      else
        nameValuePair "" null
    ) (readDir dir);

  mapModulesRec' =
    dir: fn:
    let
      dirs = mapAttrsToList (key: _: "${dir}/${key}") (
        filterAttrs filterIgnoredDirectories (readDir dir)
      );
      files = attrValues (mapModules dir id);
      paths = files ++ concatLists (map (path: mapModulesRec' path id) dirs);
    in
    map fn paths;

  mapModulesUnion = dir: fn: foldl' (acc: set: acc // set) { } (attrValues (self.mapModules dir fn));
}
