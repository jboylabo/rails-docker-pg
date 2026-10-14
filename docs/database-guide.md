# データベースガイド

## PostgreSQL とは何か

PostgreSQL は、データを表形式で保存し、SQL で問い合わせるデータベースです。このアプリではバージョン 17 を、Compose の `db` サービスとして動かします。ホストの 5432 番には公開しません。Rails コンテナが Docker ネットワーク経由で `db:5432` に接続します。

## RDBMS とは何か

Relational Database Management System の略で、関連する表の集まりを管理するソフトウェアの種類です。PostgreSQL はその一つです。ユーザー表とタスク表を、ユーザー ID で関連付けます。

## Primary Key とは何か

行を一意に識別する列です。`users.id` と `tasks.id` は bigint の主キーです。Rails が挿入時に採番します。

## Foreign Key とは何か

他の表の主キーを指す列です。`tasks.user_id` は `users.id` を指し、存在しないユーザーのタスクは作れません。データベースがこの関係を拒否します。

## Index とは何か

検索を速くするための索引です。ユーザーのメールアドレスは一意索引です。タスクは `user_id`、`(user_id, status)`、`due_at` に索引があります。一覧はログインユーザーのタスクだけを読むので、`user_id` の索引が効きます。

## NOT NULL とは何か

空の値を禁止する制約です。タスク名、状態、優先度、所有者、作成日時、更新日時は必須です。説明、期限、完了日時は空を許します。

## timestamp とは何か

日付と時刻を持つ型です。`timestamp without time zone` は、タイムゾーンを持たない壁時計の値です。その数値が UTC なのか日本時間なのかは、データベースには残りません。

## timestamptz とは何か

`timestamp with time zone` の略称です。PostgreSQL は受け取った時刻を UTC に正規化して保存し、セッションのタイムゾーンに合わせて表示します。このアプリの日時列はすべてこの型です。対象はタスクの期限、完了日時、作成日時、更新日時と、Devise の `reset_password_sent_at`、`remember_created_at`、ユーザーの作成日時、更新日時です。

Rails では `PostgreSQLAdapter.datetime_type = :timestamptz` を設定し、`t.datetime` がこの型になるようにしています。

## UTC とは何か

協定世界時です。タイムゾーンの基準です。日本時間の 2026-10-14 18:00 は、UTC の 2026-10-14 09:00 です。差は 9 時間です。

## JST とは何か

日本標準時です。UTC に 9 時間を足した時刻で、Rails の `Tokyo` と同じです。画面と `datetime-local` 入力は JST、データベースの保存値は UTC です。

## Rails と PostgreSQL のタイムゾーン

設定は三つです。

- `config.time_zone = "Tokyo"` で、表示と `Time.zone` は日本時間です。
- `config.active_record.default_timezone = :utc` で、Active Record がデータベースとやり取りする基準は UTC です。
- PostgreSQL のセッションタイムゾーンは UTC です。`database.yml` の `variables: timezone: UTC` と、サーバー起動オプション `-c timezone=UTC` で固定しています。

HTML の `datetime-local` はタイムゾーンを送りません。`2026-10-14T18:00` のような文字列は、`LocalDateTimeType` が `Time.zone.parse` で日本時間として解釈します。UTC として保存するので、9 時間ずれたまま再表示されることはありません。編集画面の値は `in_time_zone` で日本時間の文字列に戻してから入力欄へ入れます。

## Task テーブルの SQL 例

コンテナの中で `bin/rails dbconsole` を開いて実行できます。

日本時間の 18:00 を、UTC の絶対時刻として入れる例です。

```sql
INSERT INTO tasks (user_id, title, description, status, priority, due_at, created_at, updated_at)
VALUES (
  1,
  '学習',
  'Rails のタイムゾーン',
  0,
  1,
  '2026-10-14 18:00:00+09',
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP
);
```

保存値を UTC と日本時間の両方で見る例です。

```sql
SELECT
  title,
  due_at AT TIME ZONE 'UTC' AS due_at_utc,
  due_at AT TIME ZONE 'Asia/Tokyo' AS due_at_tokyo
FROM tasks;
```

自分の未完了タスクだけを、期限の近い順に見る例です。

```sql
SELECT id, title, status, priority, due_at
FROM tasks
WHERE user_id = 1
  AND status <> 2
ORDER BY due_at NULLS LAST;
```

カラム型の確認です。`timestamp with time zone` なら意図どおりです。

```sql
SELECT table_name, column_name, data_type
FROM information_schema.columns
WHERE table_name IN ('tasks', 'users')
  AND data_type LIKE 'timestamp%'
ORDER BY table_name, column_name;
```
