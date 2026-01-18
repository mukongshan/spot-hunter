import { HotAttractionsBuilder } from '../components/HotAttractions';

export interface HotAreaInfo {
  itemTitle: HotType,
  component: WrappedBuilder<[]>,
  routeEvent: (event: ClickEvent) => void
}

enum HotType {
  ATTRACTION = '热门景点'
}

export function getHotAreaInfo(pathStack: NavPathStack) {
  return [
    {
      itemTitle: HotType.ATTRACTION,
      component: wrapBuilder(HotAttractionsBuilder),
      routeEvent: () => {
        pathStack.pushPathByName('Attractions', null);
      },
    },
  ] as HotAreaInfo[];
}
