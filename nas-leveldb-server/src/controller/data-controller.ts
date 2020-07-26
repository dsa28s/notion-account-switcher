import {Get, JsonController} from 'routing-controllers';
import * as fs from 'fs';
import repository from '../repository';
import NotionNotInitializedError from '../error/notion-not-initialized-error';

@JsonController('/data')
class DataController {
  @Get('/email')
  async getCurrentLoginEmail() {
    const lockFilePath = `${repository.getNotionDataPath()}/LOCK`;
    if (fs.existsSync(lockFilePath)) {
      fs.unlinkSync(lockFilePath);
    }

    if (!fs.existsSync(repository.getNotionDataPath())) {
      throw new NotionNotInitializedError();
    }

    return repository.getLoggedInUser();
  }
}

export default DataController;
