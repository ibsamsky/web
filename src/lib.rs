use maud::{DOCTYPE, PreEscaped, html};
use worker::{Context, Env, Request, Response};

#[worker::event(fetch)]
async fn main(req: Request, _env: Env, _ctx: Context) -> worker::Result<Response> {
    let svg = PreEscaped(
        "data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'><text y='60%' x='50%' dominant-baseline='middle' text-anchor='middle' font-size='90'>🙂</text></svg>",
    );

    let markup = html! {
        (DOCTYPE)
        html {
            head {
                title { "Hello from Rust!" }
                link rel="icon" type="image/svg+xml" href=(svg);
            }
            body {
                h1 { "Hello from Rust!" }
                p { "This is a simple Worker written in Rust." }
                p { "Your request:" }
                pre style="max-width: 100vw; overflow: auto; background: #f0f0f0; padding: 10px;" { (format!("{req:#?}")) }
            }
        }
    };

    Response::from_html(markup.into_string())
}
