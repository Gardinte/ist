defmodule IstWeb.Router do
  use IstWeb, :router

  @csp [
    "default-src 'self' data: http: https:",
    "img-src 'self' https://storage.googleapis.com",
    "script-src 'self' 'unsafe-inline' resource:",
    "style-src 'self' 'unsafe-inline'",
    "worker-src blob:",
    "media-src http: https: blob:"
  ]

  @csp_headers %{"content-security-policy" => Enum.join(@csp, ";")}

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :fetch_current_session
    plug :protect_from_forgery
    plug :put_secure_browser_headers, @csp_headers
    plug :put_cache_control_headers
    plug :put_breadcrumb, name: "≡", url: "/"
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  if Mix.env() == :dev do
    forward "/sent_emails", Bamboo.SentEmailViewerPlug
  end

  scope "/", IstWeb do
    pipe_through :browser

    get "/", RootController, :index

    resources(
      "/sessions",
      SessionController,
      only: [:new, :create, :delete],
      singleton: true
    )

    # Accounts

    resources "/passwords", PasswordController, only: [:new, :create, :edit, :update]

    resources "/users", UserController

    # Recorder

    resources "/devices", DeviceController do
      resources "/recordings", RecordingController, only: [:index, :show, :delete]
    end
  end
end
