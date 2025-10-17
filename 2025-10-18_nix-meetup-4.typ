#import "@preview/touying:0.6.1": *
#import themes.simple: *
#import "@preview/cades:0.3.0": qr-code

#show: simple-theme.with(
  aspect-ratio: "16-9",
)

#show link: text => { underline[#text.body] }
#show raw.where(block: true): block.with(
  fill: luma(250),
  inset: 0.5em,
  radius: 0.5em,
  width: 100%,
  height: 1fr,
)
#set text(font: ("IBM Plex Sans JP", "Noto Emoji"))

#title-slide[
  = チームでnixを使うために考えていること（仮）
  #v(2em)
  #link("https://nix-ja.connpass.com/event/369476/")[2025-10-18 Nix meetup \#4]

  #link("https://github.com/Omochice")[Omochice]
]

== Who are you?

#grid(
  columns: (1fr, 1fr),
  [
    #image("./assets/Omochice.png", width: 80%)
  ],
  [
    #set text(size: 16pt)
    ```nix
    {
      Omochice = {
        hobby = [
          "Vim"
          "Renovate"
          "GitLab CI"
          "GitHub Actions"
          "Build optimization"
        ];
        role = [
          "frontend"
          "backend"
          "mobile"
        ];
      };
    }
    ```
  ],
)

#focus-slide(background: white, foreground: black)[
  #qr-code(
    "https://omochice.github.io/nix-slides/2025-10-18_nix-meetup-4.html",
    height: 75%,
  )
]

#focus-slide(background: white, foreground: black)[
  == Nixをおしごとで使いたい！

  #set text(fill: gray)
  (実際どれぐらい使えてますか？)
]

#focus-slide(background: white, foreground: black)[
  == Nixをおしごとで使いたい！

  - 環境の羃等性
  - #link("https://github.com/numtide/treefmt-nix")[numtide/treefmt-nix]がべんり
]

#focus-slide(background: white, foreground: black)[
  == 採用事例あるん？
]

== 採用事例の話をしよう

#grid(
  columns: (1fr, 1fr),
  align: (left, center),
  gutter: 1em,
  [
    #set align(horizon)
    - GitLab CI Component
      - Renovateをいいかんじに動かすやつ
  ],
  [
    #set text(size: 16pt)
    ```
    .
    ├── .envrc
    ├── CHANGELOG.md
    ├── CONTRIBUTING.md
    ├── flake.lock
    ├── flake.nix
    ├── README.md
    ├── renovate.json5
    └── templates
        ├── auto-merge
        │   ├── Dockerfile
        │   ├── go.mod
        │   ├── go.sum
        │   ├── main.go
        │   └── template.yml
        ├── renovate.yml
        └── validate-config.yml
    ```
  ],
)

== flake.nix

#grid(
  columns: (1fr, 1fr),
  align: (center, center),
  gutter: 1em,
  [
    #set text(size: 13pt)
    ```nix
    {
      outputs =
        { self, nixpkgs, treefmt-nix, flake-utils, nur, }:
        flake-utils.lib.eachDefaultSystem (
          system:
          let
            # 略
            treefmt = treefmt-nix.lib.evalModule pkgs (
              # 略
            );
            devPackages = rec {
              # keep-sorted start block=yes
              gitlab = [
                pkgs.gitlab-ci-ls
                pkgs.gitlab-ci-verify
                pkgs.glab
              ];
              renovate = [
                pkgs.renovate
              ];
              # keep-sorted end
    ```
  ],
  [
    #set text(size: 13pt)
    ```nix
              default = gitlab ++ renovate;
            };
          in
          {
            # keep-sorted start block=yes
            # 略
            checks = { formatting = treefmt.config.build.check self; };
            devShells =
              devPackages
              |> pkgs.lib.attrsets.mapAttrs (name: buildInputs: pkgs.mkShell { inherit buildInputs; });
            formatter = treefmt.config.build.wrapper;
            # keep-sorted end
          }
        );
    }
    ```
  ],
)

#focus-slide(background: white, foreground: black)[
  == 満を持して導入するぞ
]

#focus-slide(background: white, foreground: black)[
  #set align(left)
  #pause
  - 関数型言語むずかしいよ
  #pause
  - ツールのバージョンがわからない
  #pause
  - devcontainerがあるリポジトリでどうする
]

#focus-slide(background: white, foreground: black)[
  == #emoji.face.inv
]

== 本音

#set align(horizon)
- 関数型言語むずかしいよ
  - 頑張って覚えてほしい
- ツールのバージョンがわからない
  - https://search.nixos.org/packages を見てほしい
- devcontainerがあるリポジトリでどうする
  - #strike[Vimから使うのが大変なのでやめたい]

#focus-slide(background: white, foreground: black)[
  == そう言うと進まないので
]

#focus-slide(background: white, foreground: black)[
  == devboxを使ってみる

  #set text(size: 18pt)
  #set quote(block: true)
  #quote(attribution: [https://www.jetify.com/docs/devbox])[
    Devbox is a command-line tool that lets you easily create isolated shells for development.
    You start by defining the list of packages required for your project, and Devbox creates an isolated, reproducible environment with those packages installed.
  ]
]

#focus-slide(background: white, foreground: black)[
  == devboxを使ってみる

  #set text(size: 18pt)
  #set quote(block: true)
  #quote(attribution: [https://www.jetify.com/devbox])[
    Devbox creates isolated, reproducible development environments that run anywhere.
    No Docker containers or Nix lang required
  ]
]

#focus-slide(background: white, foreground: black)[
  == 🤔

  #set text(size: 20pt)
  #set quote(block: true)
  #quote(attribution: [https://www.jetify.com/devbox])[
    No Docker containers or Nix lang required
  ]
]

#focus-slide(background: white, foreground: black)[
  == 🤔

  それを すてるなんて とんでもない！

  #pause
  #set text(size: 24pt)

  とはいえいきなりnix言語読めってなったらつらいのかも
]

#focus-slide(background: white, foreground: black)[
  == jsonの功罪

  #grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    [
      #set text(size: 18pt)
      #set align(left)
      - 知名度、普及率は高い
        - おおよその人が読めて、だいたいの人が書ける(要出典)
          - コメント、ケツカンマ etc
        - 特段の設定なしにrenovateが更新できる
      - コマンド経由で書き換えるならいいが手で書くものではない
    ],
    [
      #set text(size: 14pt)
      ```json
      {
        "$schema": "https://raw.githubusercontent.com/jetify-com/devbox/0.16.0/.schema/devbox.schema.json",
        "packages": ["gh@2.76.1"],
        "shell": {
          "init_hook": [
            "echo 'Welcome to devbox!' > /dev/null"
          ],
          "scripts": {
            "test": [
              "echo \"Error: no test specified\" && exit 1"
            ]
          }
        }
      }
      ```
    ],
  )
]

#focus-slide(background: white, foreground: black)[
  #set text(32pt)
  #set align(left)
  - #strike[関数型言語むずかしいよ]
  - #strike[ツールのバージョンがわからない]
  - devcontainerがあるリポジトリでどうする
]

#focus-slide(background: white, foreground: black)[
  == devcontainerがあるリポジトリでどうする

  #set text(size: 18pt)
  ただのdevcontainerならbase imageをnixos/nixにしてしまってもいいかも

  Docker out of Dockerをしてると面倒だった
]

== DooD

https://github.com/Omochice/devbox-devcontainer-dood

```
.
├── .git
├── .devcontainer
│   ├── devcontainer.json
│   └── Dockerfile
├── devbox.json
└── devbox.lock
```

#[
  == Dockerfile(devbox入れるまで)

  #set text(size: 14pt)

  ```dockerfile
  FROM debian:12.12

  RUN apt-get update -y \
      && apt-get install -y --no-install-recommends \
          ca-certificates \
          curl \
          sudo \
      && rm -rf /var/lib/apt/lists/*

  ARG DEVBOX_VERSION=0.16.0
  RUN ARCH=$(uname -m | sed "s/aarch64/arm64/" | sed "s/x86_64/amd64/") \
      && curl -fsSL -o /devbox.tar.gz https://github.com/jetify-com/devbox/releases/download/${DEVBOX_VERSION}/devbox_${DEVBOX_VERSION}_linux_${ARCH}.tar.gz \
      && tar xf /devbox.tar.gz \
      && chmod +x /devbox \
      && mv /devbox /usr/local/bin/ \
      && rm /devbox.tar.gz \
      && yes | devbox cache info
  ```
]

#[
  == Dockerfile(起動shell関連)

  #set text(size: 14pt)

  ```dockerfile
  ARG USERNAME=vscode
  ARG USER_UID=1000
  ARG USER_GID=$USER_UID
  RUN groupadd --gid $USER_GID $USERNAME \
      && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
      && echo $USERNAME ALL=\(root\) NOPASSWD:ALL >/etc/sudoers.d/${USERNAME} \
      && chmod 0440 /etc/sudoers.d/$USERNAME \
      && chown -R $USERNAME /nix
  USER $USERNAME

  WORKDIR /tmp/devbox
  RUN mkdir -p /tmp/devbox && chown ${USERNAME}:${USERNAME} /tmp/devbox
  COPY --chown=${USERNAME}:${USERNAME} devbox.json devbox.json
  COPY --chown=${USERNAME}:${USERNAME} devbox.lock devbox.lock

  RUN devbox shellenv >>/home/${USERNAME}/.bashrc
  ```
]

#[
  == Help wanted

  - debian系でないと動かない
    - #quote[This Feature should work on recent versions of Debian/Ubuntu-based distributions with the apt package manager installed.]
  - 公式の```sh curl -fsSL https://get.jetify.com/devbox | bash```だと上手くいかない
    - `-s -- --force`とかでいけそうな気はするが
  - devcontainerの`postStartCommand`で`devbox shell`するとvscodeの統合terminalがこわれる
]

#focus-slide(background: white, foreground: black)[
  == 👈👷🐈

  #pause

  間に合わなかった
]

#focus-slide(background: white, foreground: black)[
  #set text(30pt)
  #set align(left)
  - Nixをおしごとで使いたいので採用事例を増やしたいよ
  - devboxなら初見でもやれそうな見た目をしてるので導入しやすいかも
    - #strike[あわよくば沼に引き摺り込みましょう]
  - #strike[devcontaienrわからん]
]
