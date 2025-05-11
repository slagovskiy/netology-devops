import sentry_sdk

sentry_sdk.init(
    dsn="http://a3cb863aba0d95546c7e85fd197dad44@127.0.0.1:9000/2",
    send_default_pii=True,
)

if __name__ == "__main__":
    print("start.")
    div_zero = 1 / 0
    print("end.")
