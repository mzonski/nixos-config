{ pkgs }:

pkgs.gnomeExtensions.pop-shell.overrideAttrs (oldAttrs: {
  postInstall = ''
    ${oldAttrs.postInstall or ""}
    # hint size and some colors
    for file in $out/share/gnome-shell/extensions/pop-shell@system76.com/{dark,light,highcontrast}.css; do
      cp -f ${./pop-shell-catpuccin.css} "$file"
    done

    # sets inactive tab background (why not covered by css, lol)
    ${pkgs.gnused}/bin/sed -i 's/#9B8E8A/#181825/g' "$out/share/gnome-shell/extensions/pop-shell@system76.com/stack.js"
  '';
})
