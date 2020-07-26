import * as os from 'os';
import * as process from 'process';

type Platform = 'aix'
    | 'android'
    | 'darwin'
    | 'freebsd'
    | 'linux'
    | 'openbsd'
    | 'sunos'
    | 'win32'
    | 'cygwin'
    | 'netbsd';

class Repository {
  getOsType(): Platform {
    return process.platform;
  }

  getNotionDataPath(): string | null {
    const userName = os.userInfo().username;

    if (this.getOsType() == 'darwin') {
      return `/Users/${userName}/Library/Applicationa Support/Notion/Partitions/notion/Local Storage/leveldb`;
    }

    return null;
  }
}

export default new Repository();
