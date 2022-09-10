import { types as T, matches as M } from "../deps.ts";
const isError = M.shape({
  error: M.string,
}).test
const isErrorCode = M.shape({
  "error-code": M.tuple(M.number, M.string),
}).test
const error = (error: string) => ({ error });
const errorCode = (code: number, error: string) => ({
  "error-code": [code, error],
}) as const;
const ok = { result: null };
/** Transform the error into ResultType, and just return the thrown ResultType */
const catchError = (effects: T.Effects) =>
  (e: unknown) => {
    if (isError(e)) return e;
    if (isErrorCode(e)) return e;
    effects.error(`Health check failed: ${e}`);
    return errorCode(61, "Health check has never run");
  };
/** Get the file contents and the metainformation */
const fullRead = (effects: T.Effects, path: string) =>
  Promise.all([
    effects.readFile({
      volumeId: "main",
      path,
    }).then((x) => x.trim()),
    effects.metadata({
      volumeId: "main",
      path,
    }),
  ]);

/**
 * We want to know the duration since the metainformation was read
 * @param metaInformation
 * @returns
 */
const calcTimeSinceLast = (metaInformation: T.Metadata) => ({
  timeSinceLast: Date.now() -
    (metaInformation.modified?.valueOf() ?? Date.now()),
});
type TimeSinceLast = ReturnType<typeof calcTimeSinceLast>;

/**
 * Make sure that the health file is updated since last check. If it isn't it means that the health check isn't running
 */
const guardForNotRecentEnough = (
  { timeSinceLast }: TimeSinceLast,
  duration: number,
) =>
  (timeSinceLast >
    duration)
    ? Promise.reject(
      error(`Health check has not run recently enough: ${timeSinceLast}ms`),
    )
    : null;

/** Call to make sure the duration is pass a minimum */
const guardDurationAboveMinimum = (
  input: { duration: number; minimumTime: number },
) =>
  (input.duration <= input.minimumTime)
    ? Promise.reject(errorCode(60, "Starting"))
    : null;

const healthVersion: T.ExpectedExports.health[""] = async (
  effects,
  duration,
) => {
  await guardDurationAboveMinimum({ duration, minimumTime: 10000 });
  const [readFile, metaInformation] = await fullRead(effects, "./health-api");

  await guardForNotRecentEnough(calcTimeSinceLast(metaInformation), duration);
  if (readFile === "0") {
    return ok;
  }
  return error(`API is unreachable`);
};
const healthWeb: T.ExpectedExports.health[""] = async (effects, duration) => {
  await guardDurationAboveMinimum({ duration, minimumTime: 11000 });
  const fetchWeb = await effects.fetch("http://lndboss.embassy/health")

  if (fetchWeb.status === 200) {
    return ok;
  }
  return error(`Fetching the website returned ${fetchWeb.status}`);
};

/** These are the health checks in the manifest */
export const health: T.ExpectedExports.health = {
  /** Checks that the server is running and reachable via cli */
  // deno-lint-ignore require-await
  async version(effects, duration) {
    return healthVersion(effects, duration).catch(catchError(effects));
  },
  /** Checks that the server is running and reachable via http */
  // deno-lint-ignore require-await
  async "web-ui"(effects, duration) {
    return healthWeb(effects, duration).catch(catchError(effects));
  },
  async "web_ui"(effects, duration) {
    return healthWeb(effects, duration).catch(catchError(effects));
  },
};
