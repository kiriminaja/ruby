# Playground

A small [Sinatra](https://sinatrarb.com) app that exposes the KiriminAja SDK endpoints for quick manual testing.

## Setup

```bash
cd playground
bundle install
```

## Run

```bash
KIRIMINAJA_API_KEY=your_key_here bundle exec ruby app.rb
```

The server starts at `http://localhost:3000`. Visit `/` to see all available routes.

## Available Routes

| Route                            | Description                   |
| -------------------------------- | ----------------------------- |
| `GET /`                          | List all routes               |
| `GET /provinces`                 | List all provinces            |
| `GET /cities/:provinsi_id`      | Cities in a province          |
| `GET /districts/:kabupaten_id`  | Districts in a city           |
| `GET /sub-districts/:kecamatan_id` | Sub-districts in a district |
| `GET /districts-by-name/:search`| Search districts by name      |
| `GET /couriers`                  | List available couriers       |
| `GET /couriers/group`           | Courier groups                |
| `GET /couriers/:code`           | Courier detail                |
| `GET /pickup/schedules`         | Pickup schedules              |
| `GET /tracking/:order_id`       | Track express order           |
| `GET /instant/tracking/:order_id` | Track instant order         |
