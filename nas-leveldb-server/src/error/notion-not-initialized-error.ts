import {HttpError} from 'routing-controllers';

class NotionNotInitializedError extends HttpError {
  constructor() {
    super(403, 'Notion data not found. Please login first from notion app.');
  }
}

export default NotionNotInitializedError;
