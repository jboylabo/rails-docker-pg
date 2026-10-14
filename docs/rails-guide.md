# Rails ガイド

このアプリは Ruby on Rails 8 の MVC アプリケーションです。API モードではありません。画面は ERB、更新は Hotwire の Turbo、見た目は Tailwind CSS v4（`tailwindcss-rails`）です。

## Rails とは何か

Rails は Ruby で Web アプリを作る枠組みです。ルーティング、データベース、画面、テストの置き場所が最初から決まっています。このアプリでは、ログインしたユーザーが自分のタスクだけを作成、表示、更新、削除します。

## MVC とは何か

役割を三つに分けた構成です。Model がデータと規則、View が HTML、Controller がリクエストと応答の橋です。ブラウザの操作は Controller に届き、Controller が Model を読み書きし、View が HTML を返します。

## Model とは何か

`app/models` のクラスです。`User` は Devise の認証を持ち、`has_many :tasks` です。`Task` は `belongs_to :user` で、状態と優先度を enum で持ちます。

状態は `pending`（未着手、0）、`in_progress`（進行中、1）、`completed`（完了、2）です。優先度は `low`（低、0）、`medium`（中、1）、`high`（高、2）です。タスク名は空にできません。完了にしたときは完了日時が空なら現在時刻を入れ、完了でなくしたときは完了日時を空にします。

期限と完了日時の入力は、タイムゾーンのない文字列を Asia/Tokyo として解釈する `local_datetime` 型を通ります。保存値は UTC です。

## View とは何か

`app/views` の ERB です。ログイン、ユーザー登録、パスワード再設定、タスクの一覧、詳細、作成、編集があります。表示言語は日本語です。日時の表示は `Time.zone`（Tokyo）で整形します。

## Controller とは何か

`TasksController` がタスクの各操作を受けます。最初に `authenticate_user!` でログインを要求します。レコードは `current_user.tasks.find` で取るので、他のユーザーのタスクは見つからず 404 になります。

## Routing とは何か

`config/routes.rb` が URL と Controller の対応です。`devise_for :users` が登録、ログイン、ログアウト、パスワード再設定です。`resources :tasks` が RESTful な七つの操作です。`root` はタスク一覧です。

| HTTP | パス | 操作 |
| --- | --- | --- |
| GET | /tasks | 一覧 |
| GET | /tasks/new | 作成画面 |
| POST | /tasks | 作成 |
| GET | /tasks/:id | 詳細 |
| GET | /tasks/:id/edit | 編集画面 |
| PATCH | /tasks/:id | 更新 |
| DELETE | /tasks/:id | 削除 |

## Active Record とは何か

Ruby のオブジェクトと PostgreSQL のテーブルを対応させるライブラリです。`Task.create!` は INSERT、`task.update` は UPDATE です。SQL を毎回手で書かずに、同じ操作を Model のメソッドで行います。

## Migration とは何か

`db/migrate` のファイルが、テーブル定義の変更履歴です。Users と Tasks を作り、その後のマイグレーションで日時カラムを `timestamp with time zone` に変換します。適用済みの番号は `schema_migrations` に記録されるので、同じマイグレーションは二度流れません。

## Validation とは何か

保存してよいかを Model で検査する規則です。タスク名が空だと保存せず、画面にエラーを返します。データベースの NOT NULL は最後の砦で、普段のエラーメッセージは Validation が出します。

## Association とは何か

Model 同士の関係です。一人の User が多数の Task を持ちます。Task は必ず一人の User に属します。ユーザーを削除すると、そのユーザーのタスクも削除されます。

## Devise とは何か

ログイン機能を提供する gem です。このアプリでは登録、ログイン、ログアウト、ログイン状態の記憶、パスワード再設定を有効にしています。再設定メールは開発環境では外部へ送らず、`tmp/mail` にファイルとして保存します。

## Strong Parameters とは何か

ブラウザから受け取ったパラメータのうち、更新してよいキーだけを残す仕組みです。タスクで許可しているのはタイトル、説明、状態、優先度、期限、完了日時です。`user_id` は許可していません。所有者は常に `current_user` です。

## コマンド

コンテナの中で実行します。ホストからは `docker compose -f compose.yaml exec web` を前置します。

### bin/rails server

開発サーバーを起動します。このプロジェクトでは `bin/docker-entrypoint` が `0.0.0.0:3000` で起動します。ホストからは `http://localhost:13000` です。

### bin/rails console

起動中のアプリと同じ Model を、対話的に操作します。`Task.count` や `User.first` を試せます。終了は `exit` です。

### bin/rails generate model

Model、マイグレーション、テストの雛形を作ります。このアプリの Task は学習用に手で定義してあります。生成しただけではテーブルは変わりません。マイグレーションの実行が別です。

### bin/rails generate controller

Controller と View の雛形を作ります。認証や `current_user.tasks` は生成後に自分で足します。

### bin/rails db:create

`config/database.yml` のデータベースを作ります。テーブルはまだありません。開発用データベースは Compose の PostgreSQL が初期作成し、`db:prepare` が不足分を補います。

### bin/rails db:migrate

未適用のマイグレーションを番号順に実行します。失敗したらそこで止まり、適用できた番号だけが記録されます。

### bin/rails db:rollback

直前のマイグレーションを一つ戻します。この学習データは Volume に残ります。戻すとテーブル定義が変わるので、実行前に何が戻るかをマイグレーションファイルで確認します。

### bin/rails routes

URL と Controller の対応一覧を出します。パスヘルパー名の確認に使います。

### bin/rails test

Minitest を実行します。登録、ログイン、タスクの作成、一覧、更新、削除、バリデーション、未ログインの拒否、他ユーザーの拒否、UTC と日本時間の変換、`timestamptz` のカラム型を検査します。
