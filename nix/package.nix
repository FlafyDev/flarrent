{ lib
, buildFlutterApp
}:

buildFlutterApp {
  pname = "flarrent";
  version = "0.1.0";

  src = ../.;

  meta = with lib; {
    description = "Frontend torrent client";
    homepage = "none";
    maintainers = [];
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
