package org.backend.spothunterserver.service;

import org.backend.spothunterserver.dto.home.HomeResponse;
import org.backend.spothunterserver.entity.Notice;
import org.backend.spothunterserver.entity.Spot;
import org.backend.spothunterserver.entity.Ticket;
import org.backend.spothunterserver.repository.NoticeRepository;
import org.backend.spothunterserver.repository.SpotRepository;
import org.backend.spothunterserver.repository.TicketRepository;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class HomeService {

    private final SpotRepository spotRepository;
    private final NoticeRepository noticeRepository;
    private final TicketRepository ticketRepository;

    public HomeService(SpotRepository spotRepository,
                      NoticeRepository noticeRepository,
                      TicketRepository ticketRepository) {
        this.spotRepository = spotRepository;
        this.noticeRepository = noticeRepository;
        this.ticketRepository = ticketRepository;
    }

    public HomeResponse getHomeData() {
        HomeResponse response = new HomeResponse();

        // 轮播图（这里简化处理，实际可以从轮播图表获取）
        response.setBanners(generateBanners());

        // 热门景点（取评分最高的前10个）
        List<Spot> hotSpots = spotRepository.findAll(
                PageRequest.of(0, 10, Sort.by(Sort.Direction.DESC, "rating"))
        ).getContent();
        response.setHotScenic(hotSpots.stream()
                .map(this::convertToHotScenic)
                .collect(Collectors.toList()));

        // 公告（取最新的前3条）
        List<Notice> notices = noticeRepository.findAllPublished().stream()
                .limit(3)
                .collect(Collectors.toList());
        response.setNotices(notices.stream()
                .map(this::convertToNotice)
                .collect(Collectors.toList()));

        // 推荐门票（取在售门票中价格最优的前几个）
        List<Ticket> tickets = ticketRepository.findAll().stream()
                .filter(t -> "ON_SALE".equals(t.getStatus()))
                .sorted((t1, t2) -> t1.getPrice().compareTo(t2.getPrice()))
                .limit(5)
                .collect(Collectors.toList());
        response.setRecommendTickets(tickets.stream()
                .map(this::convertToRecommendTicket)
                .collect(Collectors.toList()));

        return response;
    }

    private List<HomeResponse.Banner> generateBanners() {
        List<HomeResponse.Banner> banners = new ArrayList<>();
        
        // 可以从数据库获取，这里先返回示例数据
        // 实际应该从banner表或配置中获取
        
        return banners;
    }

    private HomeResponse.HotScenic convertToHotScenic(Spot spot) {
        HomeResponse.HotScenic hotScenic = new HomeResponse.HotScenic();
        hotScenic.setId(spot.getId());
        hotScenic.setName(spot.getName());
        hotScenic.setCover(spot.getCover());
        hotScenic.setLocation(spot.getLocation());
        hotScenic.setPrice(spot.getPrice());
        hotScenic.setRating(spot.getRating());
        return hotScenic;
    }

    private HomeResponse.Notice convertToNotice(Notice notice) {
        HomeResponse.Notice noticeDto = new HomeResponse.Notice();
        noticeDto.setId(notice.getId());
        noticeDto.setTitle(notice.getTitle());
        noticeDto.setSummary(notice.getSummary());
        if (notice.getPublishTime() != null) {
            noticeDto.setPublishTime(notice.getPublishTime().toLocalDate());
        }
        return noticeDto;
    }

    private HomeResponse.RecommendTicket convertToRecommendTicket(Ticket ticket) {
        HomeResponse.RecommendTicket recommendTicket = new HomeResponse.RecommendTicket();
        recommendTicket.setId(ticket.getId());
        recommendTicket.setName(ticket.getName());
        recommendTicket.setPrice(ticket.getPrice());
        recommendTicket.setOriginalPrice(ticket.getOriginalPrice());
        
        // 获取景点信息
        Spot spot = spotRepository.findById(ticket.getScenicId()).orElse(null);
        if (spot != null) {
            recommendTicket.setScenicName(spot.getName());
            recommendTicket.setScenicCover(spot.getCover());
        }
        
        return recommendTicket;
    }
}