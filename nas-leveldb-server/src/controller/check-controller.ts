import * as fs from 'fs';
import {JsonController, Post} from 'routing-controllers';
import repository from '../repository';

@JsonController('/check')
class CheckController {
  @Post('/exist-data')
  checkNotionDataExist() {
    if (fs.existsSync(repository.getNotionDataPath())) {
      return { isExist: true };
    }

    return { isExist: false };
  }
}

export default CheckController;
