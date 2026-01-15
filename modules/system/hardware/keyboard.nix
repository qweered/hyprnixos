{ pkgs, ... }:

let
  canary_eng = toString (
    pkgs.writeText "canary_eng" ''
      xkb_symbols "canary" {
          include "us(basic)"

          key <AD01> {[ w, W ]};
          key <AD02> {[ l, L ]};
          key <AD03> {[ y, Y ]};
          key <AD04> {[ p, P ]};
          key <AD05> {[ k, K ]};
          key <AD06> {[ z, Z ]};
          key <AD07> {[ x, X ]};
          key <AD08> {[ o, O ]};
          key <AD09> {[ u, U ]};
          key <AD10> {[ semicolon, colon ]};

          key <AC01> {[ c, C ]};
          key <AC02> {[ r, R ]};
          key <AC03> {[ s, S ]};
          key <AC04> {[ t, T ]};
          key <AC05> {[ b, B ]};
          key <AC06> {[ f, F ]};
          key <AC07> {[ n, N ]};
          key <AC08> {[ e, E ]};
          key <AC09> {[ i, I ]};
          key <AC10> {[ a, A ]};
          key <AC11> {[ apostrophe, quotedbl ]};

          key <AB01> {[ j, J ]};
          key <AB02> {[ v, V ]};
          key <AB03> {[ d, D ]};
          key <AB04> {[ g, G ]};
          key <AB05> {[ q, Q ]};
          key <AB06> {[ m, M ]};
          key <AB07> {[ h, H ]};
          key <AB08> {[ slash, question ]};
          key <AB09> {[ comma, less ]};
          key <AB10> {[ period, greater ]};
      };
    ''
  );

  canary_rus = toString (
    pkgs.writeText "canary_rus" ''
      xkb_symbols "rus_canary" {
          include "ru(winkeys)"

          key <AD01> {[ Cyrillic_sha, Cyrillic_SHA ]};       // w -> ш
          key <AD02> {[ Cyrillic_el, Cyrillic_EL ]};         // l -> л 
          key <AD03> {[ Cyrillic_u, Cyrillic_U ]};           // y -> у
          key <AD04> {[ Cyrillic_pe, Cyrillic_PE ]};         // p -> п
          key <AD05> {[ Cyrillic_tse, Cyrillic_TSE ]};       // k -> ц
          key <AD06> {[ Cyrillic_ze, Cyrillic_ZE ]};         // z -> з
          key <AD07> {[ Cyrillic_yeru, Cyrillic_YERU ]};     // x -> ы
          key <AD08> {[ Cyrillic_o, Cyrillic_O ]};           // o -> о
          key <AD09> {[ Cyrillic_yu, Cyrillic_YU ]};         // u -> ю
          key <AD10> {[ Cyrillic_ya, Cyrillic_YA ]};         // semicolon -> я
          key <AD11> {[ Cyrillic_che, Cyrillic_CHE ]};       // [ -> ч
          key <AD12> {[ Cyrillic_e, Cyrillic_E ]};           // ] -> э

          key <AC01> {[ Cyrillic_ka, Cyrillic_KA ]};         // c -> к
          key <AC02> {[ Cyrillic_er, Cyrillic_ER ]};         // r -> р
          key <AC03> {[ Cyrillic_es, Cyrillic_ES ]};         // s -> с
          key <AC04> {[ Cyrillic_te, Cyrillic_TE ]};         // t -> т
          key <AC05> {[ Cyrillic_be, Cyrillic_BE ]};         // b -> б
          key <AC06> {[ Cyrillic_ef, Cyrillic_EF ]};         // f -> ф
          key <AC07> {[ Cyrillic_en, Cyrillic_EN ]};         // n -> н
          key <AC08> {[ Cyrillic_ie, Cyrillic_IE, Cyrillic_yo, Cyrillic_YO ]}; // e -> е, ё
          key <AC09> {[ Cyrillic_i, Cyrillic_I ]};           // i -> и
          key <AC10> {[ Cyrillic_a, Cyrillic_A ]};           // a -> а
          key <AC11> {[ Cyrillic_shcha, Cyrillic_SHCHA ]};   // ' -> щ

          key <AB01> {[ Cyrillic_zhe, Cyrillic_ZHE ]};       // j -> ж
          key <AB02> {[ Cyrillic_ve, Cyrillic_VE ]};         // v -> в
          key <AB03> {[ Cyrillic_de, Cyrillic_DE ]};         // d -> д
          key <AB04> {[ Cyrillic_ghe, Cyrillic_GHE ]};       // g -> г
          key <AB05> {[ Cyrillic_shorti, Cyrillic_SHORTI ]}; // q -> й
          key <AB06> {[ Cyrillic_em, Cyrillic_EM ]};         // m -> м
          key <AB07> {[ Cyrillic_ha, Cyrillic_HA ]};         // h -> х
          key <AB08> {[ Cyrillic_softsign, question, Cyrillic_hardsign ]}; // ь, ?, ъ
          key <AB09> {[ comma, less ]};
          key <AB10> {[ period, greater ]};
      };
    ''
  );

in
{
  console.useXkbConfig = true;

  services.xserver.xkb = {
    layout = "canary,rus_canary";
    extraLayouts = {
      canary = {
        description = "Best layout ever";
        languages = [ "eng" ];
        symbolsFile = canary_eng;
      };
      rus_canary = {
        description = "Russian mnemonic of canary layout";
        languages = [ "rus" ];
        symbolsFile = canary_rus;
      };
    };
  };
}
