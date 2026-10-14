# Docker ガイド

この文書は、この学習アプリで使っている Docker の言葉を、初めて触る人向けに説明します。操作対象は常にこのリポジトリの Compose プロジェクト `rails8-task-learning` だけです。

## Docker とは何か

Docker は、アプリとその実行に必要な OS パッケージを一つの単位にまとめて動かす仕組みです。自分の Mac に Ruby や PostgreSQL を直接入れなくても、同じ構成を再現できます。

## Docker Image とは何か

Image は、コンテナを作るための設計図のスナップショットです。このプロジェクトでは Ruby 3.3 の公式イメージ `ruby:3.3-bookworm` を土台に、`rails8-task-learning-web` をビルドします。データベースは公式イメージ `postgres:17` をそのまま使います。

## Docker Container とは何か

Container は、Image から起動したプロセスです。止めて消しても Image は残ります。このプロジェクトのコンテナ名は Compose が `rails8-task-learning-web-1` と `rails8-task-learning-db-1` のように付けます。`container_name` は指定していません。

## Dockerfile とは何か

Dockerfile は、web 用 Image の作り方を書いたファイルです。上から順に実行され、各命令が Image の層になります。

### FROM

土台の Image を選びます。ここでは `ruby:3.3-bookworm` です。Ruby 3.3 と Debian の基本パッケージが入った状態から始まります。

### WORKDIR

以降の命令の作業ディレクトリを決めます。ここでは `/app` です。存在しなければ作られます。

### RUN

Image を作るときに実行するコマンドです。`apt-get` で `libpq-dev` などを入れ、`bundle install` で gem を Image の中へインストールします。結果は層として保存されるので、コンテナを起動するたびに再インストールしません。

### COPY

ビルドコンテキスト（このリポジトリのうち `.dockerignore` で除外していないファイル）を Image の中へコピーします。先に `Gemfile` と `Gemfile.lock` だけコピーして `bundle install` し、その後に残りのソースをコピーします。Gemfile が変わらない再ビルドでは、gem の層を使い回せます。

### ENV

Image の中の環境変数です。`BUNDLE_PATH` で gem の置き場所を固定し、`RAILS_ENV` の初期値を development にしています。データベースのパスワードはここへ書きません。実行時に `.env` から渡します。

### EXPOSE

この Image が待ち受けるポートの宣言です。Rails はコンテナ内の 3000 番です。ホストへ公開するポートは `compose.yaml` の `13000:3000` が決めます。EXPOSE だけではホストから届きません。

### CMD

コンテナ起動時の既定コマンドです。この Dockerfile の CMD は `bin/rails server` です。`compose.yaml` では、データベース準備と Tailwind のビルドをしてからサーバーを起動する `bin/docker-entrypoint` で上書きしています。

### RUN と CMD の違い

RUN は Image を作るときだけ実行されます。インストール結果が層に残ります。CMD はコンテナが起動するときに実行されます。プロセスが終わるとコンテナも終了します。依存関係のインストールは RUN、アプリの起動は CMD です。

## Docker Compose とは何か

複数のコンテナを一つの定義ファイルでまとめて起動する仕組みです。`compose.yaml` の先頭 `name: rails8-task-learning` がプロジェクト名です。Volume と Network の名前はこのプロジェクト名で始まり、他の仕事用プロジェクトと分かれます。

## Volume とは何か

Volume は、コンテナを消しても残る Docker 管理のデータ領域です。PostgreSQL のデータは `postgres_data` に保存します。`external` は使っていません。このプロジェクト専用です。

## Network とは何か

Network は、コンテナ同士が名前で通信するための専用ネットワークです。web はホスト名 `db` で PostgreSQL に接続します。名前は `app` で、このプロジェクト専用です。既存の Network は参照しません。

## Bind Mount とは何か

Bind Mount は、Mac 上のディレクトリをコンテナの中へ直接見せる接続です。`.:/app` により、エディタで保存したファイルがコンテナ内の Rails から見えます。Volume と違い、データの本体はリポジトリのファイルです。

## Docker build とは何か

Dockerfile を実行して Image を作ることです。このプロジェクトでは次だけを使います。

```bash
docker compose -f compose.yaml build web
```

## Docker run とは何か

Image からコンテナを一つ起動する Docker 単体のコマンドです。この学習では使いません。起動は Compose に任せ、他のプロジェクトのコンテナを作らないようにします。

## docker compose up とは何か

`compose.yaml` のサービスを起動します。未作成の Image があればビルドし、専用 Network と Volume を作り、db が healthy になってから web を起動します。

## docker compose down とは何か

このプロジェクトのコンテナと、Compose が作った既定の Network を止めます。Volume は残ります。データまで消す `-v` は、この学習では使いません。

## docker compose exec とは何か

すでに動いているコンテナの中でコマンドを実行します。Rails のテストやコンソールはこちらです。新しいコンテナは作りません。

## docker compose run とは何か

サービス定義を元に、一時的なコンテナを追加で起動してコマンドを実行します。`--rm` を付けると、コマンド終了後にその一時コンテナだけを削除します。他のプロジェクトのコンテナは消しません。

## docker compose logs とは何か

このプロジェクトのコンテナが出力したログを表示します。`-f` を付けると、新しい行を追って表示し続けます。

## 四つのコマンドの違い

| コマンド | 対象 | コンテナ |
| --- | --- | --- |
| `docker run` | Image を直接指定して起動する | 新しく作る |
| `docker exec` | すでに動いているコンテナ | 作らない |
| `docker compose run` | この compose.yaml のサービス | 一時コンテナを作る |
| `docker compose exec` | このプロジェクトで起動済みのサービス | 作らない |

`exec` は起動中の Rails と同じ環境でコマンドを足すときに使います。`run` は、web が止まっていても一度だけコマンドを走らせたいときに使います。どちらも、このリポジトリで `docker compose -f compose.yaml` を付けて実行します。

## .dockerignore と .gitignore の違い

`.gitignore` は Git にコミットしないファイルを決めます。`.dockerignore` は `docker build` が Image へ送るファイルを決めます。Git に入っていても Image には不要、というファイルを除外できます。

### Docker build context とは何か

`docker compose build` が Docker エンジンへ送るファイル一式です。このリポジトリが対象です。context が大きいとビルドが遅くなり、秘密や無関係なファイルが Image に入ります。

### なぜ .git を除外するのか

履歴はアプリの実行に不要で、context を大きくします。Image にリポジトリ履歴を入れないため除外します。

### なぜ .env を除外するのか

データベースのパスワードが入るためです。Image の層にパスワードが残ると、Image をコピーした人から読めてしまいます。実行時は Compose の `env_file` で渡します。`.env.example` は値の見本なので、除外規則の例外にしています。

### なぜ node_modules を除外するのか

このアプリの CSS は `tailwindcss-rails` が Ruby の中でビルドします。ホストに `node_modules` ができても Image には不要で、context を膨らませます。

### .dockerignore が Image に与える影響

除外したファイルは COPY の対象外です。Image は小さくなり、秘密やログが層に残りにくくなります。`Gemfile`、`app`、`config`、`bin` など起動に必要なファイルは除外していません。`docs` は実行に不要なので除外しています。
