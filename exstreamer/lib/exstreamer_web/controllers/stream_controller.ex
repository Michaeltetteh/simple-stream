defmodule ExstreamerWeb.StreamController do
  @moduledoc """
  Serves video files and poster images with HTTP Range request support.
  Videos are served from priv/uploads/videos/, posters from priv/uploads/posters/.
  Range requests (HTTP 206 Partial Content) allow seeking in the video player.
  """
  use ExstreamerWeb, :controller

  alias Exstreamer.MediaCatalog

  @video_dir Application.app_dir(:exstreamer, "priv/uploads/videos")
  @poster_dir Application.app_dir(:exstreamer, "priv/uploads/posters")

  # ── Video streaming with Range support ──────────────────────────────────────

  def video(conn, %{"file_id" => file_id}) do
    file = MediaCatalog.get_media_file!(file_id)
    path = Path.join(@video_dir, Path.basename(file.path))

    unless File.exists?(path) do
      conn
      |> put_status(:not_found)
      |> text("File not found")
      |> halt()
    else
      file_size = File.stat!(path).size
      content_type = mime_type(file.name)

      case get_req_header(conn, "range") do
        ["bytes=" <> range_spec] ->
          serve_range(conn, path, file_size, content_type, range_spec)

        _ ->
          conn
          |> put_resp_header("content-type", content_type)
          |> put_resp_header("content-length", Integer.to_string(file_size))
          |> put_resp_header("accept-ranges", "bytes")
          |> send_file(200, path)
      end
    end
  end

  # ── Poster images ────────────────────────────────────────────────────────────

  def poster(conn, %{"filename" => filename}) do
    # Sanitise: reject path traversal
    safe_name = Path.basename(filename)
    path = Path.join(@poster_dir, safe_name)

    if File.exists?(path) do
      conn
      |> put_resp_header("content-type", mime_type(safe_name))
      |> put_resp_header("cache-control", "public, max-age=86400")
      |> send_file(200, path)
    else
      conn
      |> put_status(:not_found)
      |> text("Not found")
      |> halt()
    end
  end

  # ── Private helpers ──────────────────────────────────────────────────────────

  defp serve_range(conn, path, file_size, content_type, range_spec) do
    case parse_range(range_spec, file_size) do
      {:ok, start_byte, end_byte} ->
        length = end_byte - start_byte + 1

        conn
        |> put_resp_header("content-type", content_type)
        |> put_resp_header("content-range", "bytes #{start_byte}-#{end_byte}/#{file_size}")
        |> put_resp_header("content-length", Integer.to_string(length))
        |> put_resp_header("accept-ranges", "bytes")
        |> send_file(206, path, start_byte, length)

      :error ->
        conn
        |> put_resp_header("content-range", "bytes */#{file_size}")
        |> put_status(416)
        |> text("Range Not Satisfiable")
        |> halt()
    end
  end

  defp parse_range(range_spec, file_size) do
    case String.split(range_spec, "-") do
      [start_str, ""] ->
        with {start_byte, ""} <- Integer.parse(start_str),
             true <- start_byte >= 0 and start_byte < file_size do
          {:ok, start_byte, file_size - 1}
        else
          _ -> :error
        end

      [start_str, end_str] ->
        with {start_byte, ""} <- Integer.parse(start_str),
             {end_byte, ""} <- Integer.parse(end_str),
             true <- start_byte >= 0,
             true <- end_byte >= start_byte,
             true <- end_byte < file_size do
          {:ok, start_byte, end_byte}
        else
          _ -> :error
        end

      _ ->
        :error
    end
  end

  defp mime_type(filename) do
    ext = filename |> Path.extname() |> String.downcase()

    case ext do
      ".mp4" -> "video/mp4"
      ".webm" -> "video/webm"
      ".ogv" -> "video/ogg"
      ".mkv" -> "video/x-matroska"
      ".mov" -> "video/quicktime"
      ".jpg" -> "image/jpeg"
      ".jpeg" -> "image/jpeg"
      ".png" -> "image/png"
      ".webp" -> "image/webp"
      ".gif" -> "image/gif"
      _ -> "application/octet-stream"
    end
  end
end
