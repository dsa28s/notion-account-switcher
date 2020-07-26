import {createLogger, Logger, outputs, setLevel, setOutput} from '@ekino/logger';

class Log {
  private static instance: Log;
  private logger: Logger;

  private constructor() {
    Log.instance = this;

    setLevel('debug');
    setOutput(outputs.pretty);
    this.logger = createLogger('nas:leveldb-server');
  }

  static get shared() {
    if (!Log.instance) {
      Log.instance = new Log();
    }

    return this.instance;
  }

  info(message: string, extra?: string): void {
    this.logger.info(message, extra);
  }

  warning(message: string, extra?: string): void {
    this.logger.warn(message, extra);
  }

  error(message: string, extra?: string): void {
    this.logger.error(message, extra);
  }
}

export default Log;
