export interface FunctionModuleData {
  id: FunctionType;
  title: ResourceStr;
  icon: ResourceStr;
  click: (event: ClickEvent) => void;
}

export enum FunctionType {
  TICKET = 0,
  BULLETIN = 1,
}

export enum FunctionPath {
  TICKET = 'Tickets',
  BULLETIN = 'Bulletins',
}

export function getFunctionModuleInfo(pathStack: NavPathStack) {
  return [
    {
      id: FunctionType.TICKET,
      title: '票务预约',
      icon: $r('app.media.ticket'),
      click: () => {
        pathStack.pushPathByName(FunctionPath.TICKET, true);
      },
    },
    {
      id: FunctionType.BULLETIN,
      title: '公告通知',
      icon: $r('app.media.ticket'),  // 暂时使用ticket图标,后续可替换
      click: () => {
        pathStack.pushPathByName(FunctionPath.BULLETIN, null);
      },
    },
  ] as FunctionModuleData[];
}