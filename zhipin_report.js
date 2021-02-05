let url = "https://us-central1-nexa-1181.cloudfunctions.net/zhipin_report";

let blue_color = "#4B87FF";

function close_app(packageName) {
    var name = getPackageName(packageName); 
    if(!name){
        if(getAppName(packageName)){
            name = packageName;
        }else{
            return false;
        } 
    }
    app.openAppSetting(name);
    text(app.getAppName(name)).waitFor();  
    let is_sure = textMatches(/(.*强.*|.*行.*|.*停.*|.*止.*)/).findOne();

    if (is_sure.enabled()) {
        var sleep_time = 3000 + random(1,3)*1000;
        sleep(sleep_time);
        toast("sleep " + sleep_time);
        if(id("right_button").exists()){
            id("right_button").click();
        }
        
        var sleep_time = 3000 + random(1,3)*1000;
        sleep(sleep_time);
        toast("sleep " + sleep_time);
        if(className("android.widget.Button").depth(5).indexInParent(1).exists()){
            className("android.widget.Button").depth(5).indexInParent(1).findOne().click();
        }
        if(className("android.widget.Button").depth(1).indexInParent(3).exists()){
            className("android.widget.Button").depth(1).indexInParent(3).findOne().click();
        }
        console.info(app.getAppName(name) + "应用已被关闭");
        toast(app.getAppName(name) + "应用已被关闭");
        var sleep_time = 1000 + random(1,3)*1000;
        sleep(sleep_time);
        toast("sleep " + sleep_time);
        back();
    } else {
        console.info(app.getAppName(name) + "应用不能被正常关闭或不在后台运行");
        back();
    }
}

function CurentTime(){ 
    var now = new Date();
    var year = now.getFullYear();       //年
    var month = now.getMonth() + 1;     //月
    var day = now.getDate();            //日
    var hh = now.getHours();            //时
    var mm = now.getMinutes();          //分
    var clock = year + "-";
    if(month < 10)
        clock += "0";
    clock += month + "-";
    if(day < 10)
        clock += "0"; 
    clock += day + " ";
    if(hh < 10)
        clock += "0";
    clock += hh + ":";
    if (mm < 10) clock += '0'; 
    clock += mm; 
    return(clock);
}

function detect_arrow_color(arrow){
    var arrow_bounds = arrow.bounds();
    var arrow_x = arrow_bounds.centerX();
    var arrow_y = arrow_bounds.centerY();
    var arrow_color = colors.toString(images.pixel(captureScreen(), arrow_x, arrow_y));
    if(colors.isSimilar(blue_color,arrow_color)){
        return "-";
    }else{
        return "+";
    };
}

function crawl_report_data(position_name, position_index){
    if(position_index === 0){
        position_name = "全部";
    }
    console.info("===================");
    console.info("Crawl report data of " + position_name);
    toast("Crawl report data of " + position_name);
    if(className("android.view.View").depth(14).indexInParent(2).exists()){
        console.info("UI => 2");
        toast("UI => 2");
        var today_viewed = className("android.view.View").depth(14).indexInParent(2).findOne().text();
        console.info("今日我看过 " + today_viewed);
        toast("今日我看过 " + today_viewed);

        var today_contacted = className("android.view.View").depth(14).indexInParent(5).findOne().text();
        console.info("今日联系我的人 " + today_contacted);
        toast("今日联系我的人 " + today_contacted);

        if(!className("android.view.View").depth(14).indexInParent(14).exists() && ui_style === "2"){
            console.info("Again, try to `展开数据`");
            toast("Again, try to `展开数据`");
            id("webview_layout").depth(7).indexInParent(0).findOne().find(className("android.view.View").depth(15).indexInParent(0))[5].click();
        }

        var today_get_resume = className("android.view.View").depth(14).indexInParent(11).findOne().text();
        console.info("今日获取简历 " + today_get_resume);
        toast("今日获取简历 " + today_get_resume);

        var today_wechat = className("android.view.View").depth(14).indexInParent(14).findOne().text();
        console.info("今日交换电话微信 " + today_wechat);
        toast("今日交换电话微信 " + today_wechat);

        if(className("android.view.View").depth(14).indexInParent(17).exists()){
            var today_interview = className("android.view.View").depth(14).indexInParent(17).findOne().text();
            console.info("今日邀约面试 " + today_interview);
            toast("今日邀约面试 " + today_interview);
        }else{
            var today_interview = "";
        }
        
        var today_communicate = className("android.view.View").depth(14).indexInParent(8).findOne().text();
        console.info("今日沟通牛人 " + today_communicate);
        toast("今日沟通牛人 " + today_communicate);

        var compare_yester_viewed = className("android.view.View").depth(14).indexInParent(3).findOne().findOne(className("android.view.View").depth(15).indexInParent(2)).text();
        var compare_yester_viewed_arrow = className("android.view.View").depth(14).indexInParent(3).findOne().findOne(className("android.view.View").depth(15).indexInParent(1));
        var compare_yester_viewed_arrow_prefix = detect_arrow_color(compare_yester_viewed_arrow);
        compare_yester_viewed = compare_yester_viewed_arrow_prefix + compare_yester_viewed;
        console.info("相较昨日我看过 " + compare_yester_viewed);
        toast("相较昨日我看过 " + compare_yester_viewed);

        var compare_yester_contacted = className("android.view.View").depth(14).indexInParent(6).findOne().findOne(className("android.view.View").depth(15).indexInParent(2)).text();
        var compare_yester_contacted_arrow = className("android.view.View").depth(14).indexInParent(6).findOne().findOne(className("android.view.View").depth(15).indexInParent(1));
        var compare_yester_contacted_arrow_prefix = detect_arrow_color(compare_yester_contacted_arrow);
        compare_yester_contacted = compare_yester_contacted_arrow_prefix + compare_yester_contacted;
        console.info("相较昨日联系我的人 " + compare_yester_contacted);
        toast("相较昨日联系我的人 " + compare_yester_contacted);

        var compare_yester_get_resume = className("android.view.View").depth(14).indexInParent(12).findOne().findOne(className("android.view.View").depth(15).indexInParent(2)).text();
        var compare_yester_get_resume_arrow = className("android.view.View").depth(14).indexInParent(12).findOne().findOne(className("android.view.View").depth(15).indexInParent(1));
        var compare_yester_get_resume_arrow_prefix = detect_arrow_color(compare_yester_get_resume_arrow);
        compare_yester_get_resume = compare_yester_get_resume_arrow_prefix + compare_yester_get_resume;
        console.info("相较昨日获取简历 " + compare_yester_get_resume);
        toast("相较昨日获取简历 " + compare_yester_get_resume);

        var compare_yester_wechat = className("android.view.View").depth(14).indexInParent(15).findOne().findOne(className("android.view.View").depth(15).indexInParent(2)).text();
        var compare_yester_wechat_arrow = className("android.view.View").depth(14).indexInParent(15).findOne().findOne(className("android.view.View").depth(15).indexInParent(1));
        var compare_yester_wechat_arrow_prefix = detect_arrow_color(compare_yester_wechat_arrow);
        compare_yester_wechat = compare_yester_wechat_arrow_prefix + compare_yester_wechat;
        console.info("相较昨日交换电话微信 " + compare_yester_wechat);
        toast("相较昨日交换电话微信 " + compare_yester_wechat);
        
        if(className("android.view.View").depth(14).indexInParent(18).exists()){
            var compare_yester_interview = className("android.view.View").depth(14).indexInParent(18).findOne().findOne(className("android.view.View").depth(15).indexInParent(2)).text();
            var compare_yester_interview_arrow = className("android.view.View").depth(14).indexInParent(18).findOne().findOne(className("android.view.View").depth(15).indexInParent(1));
            var compare_yester_interview_arrow_prefix = detect_arrow_color(compare_yester_interview_arrow);
            compare_yester_interview = compare_yester_interview_arrow_prefix + compare_yester_interview;
            console.info("相较昨日邀约面试 " + compare_yester_interview);
            toast("相较昨日邀约面试 " + compare_yester_interview);
        }else{
            compare_yester_interview = "";
        }
        
        var compare_yester_communicate = className("android.view.View").depth(14).indexInParent(9).findOne().findOne(className("android.view.View").depth(15).indexInParent(2)).text();
        var compare_yester_communicate_arrow = className("android.view.View").depth(14).indexInParent(9).findOne().findOne(className("android.view.View").depth(15).indexInParent(1));
        var compare_yester_communicate_arrow_prefix = detect_arrow_color(compare_yester_communicate_arrow);
        compare_yester_communicate = compare_yester_communicate_arrow_prefix + compare_yester_communicate;
        console.info("相较昨日沟通牛人 " + compare_yester_communicate);
        toast("相较昨日沟通牛人 " + compare_yester_communicate);
    }else{
        console.info("UI => 1");
        toast("UI => 1");
        var today_viewed = className("android.view.View").depth(6).indexInParent(2).findOne().text();
        console.info("今日我看过 " + today_viewed);
        toast("今日我看过 " + today_viewed);

        var today_contacted = className("android.view.View").depth(6).indexInParent(5).findOne().text();
        console.info("今日联系我的人 " + today_contacted);
        toast("今日联系我的人 " + today_contacted);

        if(!className("android.view.View").depth(6).indexInParent(14).exists() && ui_style === "1"){
            console.info("Again, try to `展开数据`");
            toast("Again, try to `展开数据`");
            className("android.view.View").text("展开更多数据").findOne().click();
        }

        var today_get_resume = className("android.view.View").depth(6).indexInParent(11).findOne().text();
        console.info("今日获取简历 " + today_get_resume);
        toast("今日获取简历 " + today_get_resume);

        var today_wechat = className("android.view.View").depth(6).indexInParent(14).findOne().text();
        console.info(today_wechat);
        if(className("android.view.View").depth(6).indexInParent(17).exists()){
            var today_interview = className("android.view.View").depth(6).indexInParent(17).findOne().text();
            console.info("今日邀约面试 " + today_interview);
            toast("今日邀约面试 " + today_interview);
        }else{
            var today_interview = "";
        }
        
        console.info(today_interview);
        var today_communicate = className("android.view.View").depth(6).indexInParent(8).findOne().text();
        console.info("今日沟通牛人 " + today_communicate);
        toast("今日沟通牛人 " + today_communicate);

        className("android.view.View").depth(6).indexInParent(3).findOne().findOne(className("android.view.View").depth(7).indexInParent(1)).text();

        var compare_yester_viewed = className("android.view.View").depth(6).indexInParent(3).findOne().findOne(className("android.view.View").depth(7).indexInParent(2)).text();
        var compare_yester_viewed_arrow = className("android.view.View").depth(6).indexInParent(3).findOne().findOne(className("android.view.View").depth(7).indexInParent(1));
        var compare_yester_viewed_arrow_prefix = detect_arrow_color(compare_yester_viewed_arrow);
        compare_yester_viewed = compare_yester_viewed_arrow_prefix + compare_yester_viewed;
        console.info("相较昨日我看过 " + compare_yester_viewed);
        toast("相较昨日我看过 " + compare_yester_viewed);

        var compare_yester_contacted = className("android.view.View").depth(6).indexInParent(6).findOne().findOne(className("android.view.View").depth(7).indexInParent(2)).text();
        var compare_yester_contacted_arrow = className("android.view.View").depth(6).indexInParent(6).findOne().findOne(className("android.view.View").depth(7).indexInParent(1));
        var compare_yester_contacted_arrow_prefix = detect_arrow_color(compare_yester_contacted_arrow);
        compare_yester_contacted = compare_yester_contacted_arrow_prefix + compare_yester_contacted;
        console.info("相较昨日联系我的人 " + compare_yester_contacted);
        toast("相较昨日联系我的人 " + compare_yester_contacted);

        var compare_yester_get_resume = className("android.view.View").depth(6).indexInParent(12).findOne().findOne(className("android.view.View").depth(7).indexInParent(2)).text();
        var compare_yester_get_resume_arrow = className("android.view.View").depth(6).indexInParent(12).findOne().findOne(className("android.view.View").depth(7).indexInParent(1));
        var compare_yester_get_resume_arrow_prefix = detect_arrow_color(compare_yester_get_resume_arrow);
        compare_yester_get_resume = compare_yester_get_resume_arrow_prefix + compare_yester_get_resume;
        console.info("相较昨日获取简历 " + compare_yester_get_resume);
        toast("相较昨日获取简历 " + compare_yester_get_resume);
        
        var compare_yester_wechat = className("android.view.View").depth(6).indexInParent(15).findOne().findOne(className("android.view.View").depth(7).indexInParent(2)).text();
        var compare_yester_wechat_arrow = className("android.view.View").depth(6).indexInParent(15).findOne().findOne(className("android.view.View").depth(7).indexInParent(1));
        var compare_yester_wechat_arrow_prefix = detect_arrow_color(compare_yester_wechat_arrow);
        compare_yester_wechat = compare_yester_wechat_arrow_prefix + compare_yester_wechat;
        console.info("相较昨日交换电话微信 " + compare_yester_wechat);
        toast("相较昨日交换电话微信 " + compare_yester_wechat);
        
        if(compare_yester_interview = className("android.view.View").depth(6).indexInParent(18).exists()){
            var compare_yester_interview = className("android.view.View").depth(6).indexInParent(18).findOne().findOne(className("android.view.View").depth(7).indexInParent(2)).text();
            var compare_yester_interview_arrow = className("android.view.View").depth(6).indexInParent(18).findOne().findOne(className("android.view.View").depth(7).indexInParent(1));
            var compare_yester_interview_arrow_prefix = detect_arrow_color(compare_yester_interview_arrow);
            compare_yester_interview = compare_yester_interview_arrow_prefix + compare_yester_interview;
            console.info("相较昨日邀约面试 " + compare_yester_interview);
            toast("相较昨日邀约面试 " + compare_yester_interview);
        }else{
            compare_yester_interview = "";
        }
        
        var compare_yester_communicate = className("android.view.View").depth(6).indexInParent(9).findOne().findOne(className("android.view.View").depth(7).indexInParent(2)).text();
        var compare_yester_communicate_arrow = className("android.view.View").depth(6).indexInParent(9).findOne().findOne(className("android.view.View").depth(7).indexInParent(1));
        var compare_yester_communicate_arrow_prefix = detect_arrow_color(compare_yester_communicate_arrow);
        compare_yester_communicate = compare_yester_communicate_arrow_prefix + compare_yester_communicate;
        console.info("相较昨日沟通牛人 " + compare_yester_communicate);
        toast("相较昨日沟通牛人 " + compare_yester_communicate);
    }
    
    var payload = {"today_viewed": today_viewed,
                   "compare_viewed": compare_yester_viewed,
                   "today_contacted": today_contacted,
                   "compare_contacted": compare_yester_contacted,
                   "today_get_resume": today_get_resume,
                   "compare_get_resume": compare_yester_get_resume,
                   "today_wechat": compare_yester_wechat,
                   "compare_wechat": compare_yester_wechat,
                   "today_interview": today_interview,
                   "compare_interview": compare_yester_interview,
                   "today_communicate": today_communicate,
                   "compare_communicate": compare_yester_communicate,
                   "boss_name": boss_name,
                   "company": company,
                   "report_time": report_time,
                   "position_name": position_name,
                   "position_index": position_index
                  }
    let res = http.postJson(url, JSON.stringify(payload));
    let html_content = res.body.string();  //取页面html源码
    let json_content = JSON.parse(html_content);
    console.info("Upload data to aliyun");
    toast("Upload data to aliyun");
}

auto.waitFor();
var appName = "BOSS直聘";
console.info("截屏授权");
toast("截屏授权");
requestScreenCapture(false);
launchApp(appName);
var sleep_time = 3000 + random(1,3)*1000;
sleep(sleep_time);
toast("sleep " + sleep_time);
toast("Launch app - " + appName);
var report_time = CurentTime();

var sleep_time = 3000 + random(1,3)*1000;
sleep(sleep_time);
toast("sleep " + sleep_time);

var home = id("cl_tab_4").findOne();
var boss_name = "";
var boss_company = "";

toast("home_button clickable" + home.clickable());
console.info("home_button clickable" + home.clickable());
if(home && home.clickable()){
    home.click();
    toast("Switch to `我的` tag");
    console.info("Switch to `我的` tag");
    var sleep_time = 4000 + random(1,3)*1000;
    sleep(sleep_time);
    toast("sleep " + sleep_time);
    id("rl_boss_base_info").findOne().click();
    var sleep_time = 2000 + random(1,3)*1000;
    sleep(sleep_time);
    toast("sleep " + sleep_time);
    var boss_name = id("tv_name").findOne().text();
    var company = id("tv_brand").findOne().text();
    console.info("boss_name " + boss_name);
    toast("boss_name " + boss_name);
    console.info("boss_company " + company);
    toast("boss_company " + company);
    id("iv_back").findOne().click();
    var sleep_time = 3000 + random(1,3)*1000;
    sleep(sleep_time);
    toast("sleep " + sleep_time);
    
    if(className("android.view.ViewGroup").depth(2).indexInParent(4).exists()){
        className("android.view.ViewGroup").depth(2).indexInParent(4).click();
    }
    if(className("android.view.ViewGroup").depth(14).indexInParent(0).exists()){
        className("android.view.ViewGroup").depth(14).indexInParent(0).click();
    }
    
    var sleep_time = 5000 + random(1,3)*1000;
    sleep(sleep_time);
    toast("sleep " + sleep_time);

    var sleep_time = 10000 + random(1,3)*1000;
    sleep(sleep_time);
    toast("sleep " + sleep_time);
    var ui_style = "";

    if(className("android.view.View").text("展开更多数据").exists()){
        console.info("Try to `展开数据`");
        toast("Try to `展开数据`");
        ui_style = "1";
        className("android.view.View").text("展开更多数据").findOne().click();
    }
    
    if(id("webview_layout").depth(7).indexInParent(0).exists() && id("webview_layout").depth(7).indexInParent(0).findOne().find(className("android.view.View").depth(15).indexInParent(0))[5].text() === "展开更多数据"){
        console.info("Try to `展开数据`");
        toast("Try to `展开数据`");
        ui_style = "2";
        id("webview_layout").depth(7).indexInParent(0).findOne().find(className("android.view.View").depth(15).indexInParent(0))[5].click();
    }

    var positions = className("android.widget.ListView").scrollable(true).findOne().children();
    positions.forEach(function(item, i){
        var sleep_time = 5000 + random(1,3)*1000;
        sleep(sleep_time);
        toast("sleep " + sleep_time);
        console.info("---------------------");
        var position_name = item.text();
        var position_index = item.indexInParent();
        console.info("position_name " + position_name);
        toast("position_name " + position_name);
        item.click();
        var sleep_time = 5000 + random(1,3)*1000;
        sleep(sleep_time);
        toast("sleep " + sleep_time);
        crawl_report_data(position_name, position_index, ui_style);
    });    
}else{
    toast("`我的` tag没找到耶，请关闭app重来盘");
    console.info("`我的` tag没找到耶，请关闭app重来盘");
}
var sleep_time = 3000 + random(1,3)*1000;
sleep(sleep_time);
toast("sleep " + sleep_time);
toast("Finished!!!");
console.info("Finished!!!");
close_app(appName);
