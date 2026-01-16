package org.backend.spothunterserver.controller;

import org.backend.spothunterserver.dto.common.ApiResponse;
import org.backend.spothunterserver.dto.home.HomeResponse;
import org.backend.spothunterserver.service.HomeService;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/home")
public class HomeController {

    private final HomeService homeService;

    public HomeController(HomeService homeService) {
        this.homeService = homeService;
    }

    @GetMapping
    public ApiResponse<HomeResponse> getHomeData() {
        HomeResponse response = homeService.getHomeData();
        return ApiResponse.success(response);
    }
}