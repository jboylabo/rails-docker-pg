# タスク学習アプリ

ログインしたユーザーが、自分のタスクを作成、閲覧、更新、削除する Rails 8 の学習用アプリケーションです。日時は画面では日本時間、PostgreSQL では `timestamp with time zone`（UTC）です。

Docker の操作はこのリポジトリの `compose.yaml` だけを対象にします。プロジェクト名は `rails8-task-learning` です。仕事用のコンテナ、Image、Volume、Network は起動、停止、削除しません。

## 技術構成

- Ruby 3.3
- Rails 8（MVC。API モードではない）
- PostgreSQL 17
- Docker Compose v2
- Devise
- Active Record
- Tailwind CSS v4（`tailwindcss-rails`。Node.js のビルドは使わない）
- Hotwire / Turbo
- ERB
- Minitest

## 必要なソフトウェア

- Docker Desktop（起動済みであること。停止している場合は、この手順では起動しません）
- Docker Compose v2（`docker compose`）

Ruby と PostgreSQL を Mac へ直接インストールする必要はありません。

## 初回セットアップ

リポジトリのルートで実行します。

```bash
cp .env.example .env
```

`.env` は Git に含めません。パスワードを変えた場合は、データベースを作り直す前に変えてください。既定のホスト側ポートは 13000 です。13000 が使用中なら、そのプロセスは止めずに `WEB_PORT` を空いている番号へ変更します。

## Docker イメージのビルド

```bash
docker compose -f compose.yaml build web
```

db は公式イメージ `postgres:17` を使います。web は `ruby:3.3-bookworm` から `rails8-task-learning-web` を作ります。

## コンテナの起動

```bash
docker compose -f compose.yaml up -d
```

db が healthy になったあと、web がマイグレーションを適用して Rails を起動します。

## DB の作成

開発用データベース名は `.env` の `POSTGRES_DB`（既定は `task_learning_development`）です。PostgreSQL の初回起動時に作られ、web の `bin/rails db:prepare` が不足していれば作成します。テスト用は `task_learning_test` です。

## マイグレーション

起動時に development の未適用マイグレーションが流れます。手動で流す場合は次です。

```bash
docker compose -f compose.yaml exec web bin/rails db:migrate
```

## Rails へのアクセス

ブラウザで次を開きます。`WEB_PORT` を変えた場合はその番号です。

```text
http://localhost:13000
```

未ログインではログイン画面へ移動します。

## ユーザー登録

画面の「ユーザー登録」からメールアドレスとパスワード（6 文字以上）を登録します。登録後はログイン状態になり、タスク一覧が開きます。

## Task の CRUD 操作

ログイン後に一覧、詳細、新規作成、編集、削除ができます。削除は確認ダイアログのあとで実行されます。他のユーザーのタスクは URL を知っていても開けません。

期限は日本時間として入力します。例として 2026-10-14 18:00 と入れると、データベースには UTC の 2026-10-14 09:00 が保存され、画面には再び 18:00 と出ます。

## Rails コンソールの起動

```bash
docker compose -f compose.yaml exec web bin/rails console
```

## PostgreSQL への接続

5432 番はホストへ公開していません。接続は web コンテナから行います。

```bash
docker compose -f compose.yaml exec web bin/rails dbconsole
```

## テストの実行

```bash
docker compose -f compose.yaml exec web bin/rails db:test:prepare
docker compose -f compose.yaml exec web bin/rails test
```

## ログの確認

```bash
docker compose -f compose.yaml logs -f web
```

パスワード再設定メールは送信サービスへ送らず、コンテナ内の `tmp/mail` にファイルで残します。

```bash
docker compose -f compose.yaml exec web ls tmp/mail
```

## コンテナの停止

```bash
docker compose -f compose.yaml down
```

Volume は残します。`-v` は付けません。データと他の Docker プロジェクトを消す操作は行いません。

## よくあるエラーと対処方法

**ポート 13000 が使用中**

既存のプロセスは止めません。`.env` の `WEB_PORT` を空いている番号に変えて、`docker compose -f compose.yaml up -d` をやり直します。

**web が db に接続できない**

`docker compose -f compose.yaml ps` で db が healthy かを見ます。`.env` のユーザー名、パスワード、データベース名が、最初に Volume を作ったときの値と一致している必要があります。パスワードだけ後から変えても、既存 Volume の初期ユーザーは変わりません。

**gem を追加したあと起動に失敗する**

Image の中の gem が古いです。

```bash
docker compose -f compose.yaml up -d --build
```

**画面の CSS が古い**

web 起動時に Tailwind をビルドします。クラスを足したあとに反映されないときは次を実行します。

```bash
docker compose -f compose.yaml exec web bin/rails tailwindcss:build
```

**マイグレーションエラー**

`docker compose -f compose.yaml logs web` で SQL エラーを確認します。データベースの削除や `docker compose down -v` では直さず、マイグレーションファイルを修正してから `db:migrate` を再実行します。

## さらに読む

- [Docker の言葉](docs/docker-guide.md)
- [コマンドの意味](docs/commands.md)
- [Rails の言葉](docs/rails-guide.md)
- [PostgreSQL とタイムゾーン](docs/database-guide.md)
