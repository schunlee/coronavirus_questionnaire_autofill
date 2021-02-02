let url = "https://us-central1-nexa-1181.cloudfunctions.net/zhipin_report";

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
        sleep(3000);
        textMatches("强行停止").findOne().click();
        sleep(3000);
        textMatches("强行停止").findOne().click();

        log(app.getAppName(name) + "应用已被关闭");
        sleep(1000);
        back();
    } else {
        log(app.getAppName(name) + "应用不能被正常关闭或不在后台运行");
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


auto.waitFor();
var appName = "BOSS直聘";
launchApp(appName);
sleep(3000);
toast("Launch app - " + appName);
var report_time = CurentTime();

var home = id("cl_tab_4").findOnce();
if(home && home.clickable()){
    home.click();
    sleep(4000);
    id("rl_boss_base_info").findOne().click();
    sleep(2000);
    var boss_name = id("tv_name").findOne().text()
    var company = id("tv_brand").findOne().text()
    console.info(boss_name);
    console.info(company);
    id("iv_back").findOne().click();
    sleep(3000);
    // className("android.view.ViewGroup").depth(2).indexInParent(4).click();
    
    if(className("android.view.ViewGroup").depth(2).indexInParent(4).exists()){
        className("android.view.ViewGroup").depth(2).indexInParent(4).click();
    }
    if(className("android.view.ViewGroup").depth(14).indexInParent(0).exists()){
        className("android.view.ViewGroup").depth(14).indexInParent(0).click();
    }
    
    
    sleep(4000);
    console.info("111111111");
    if(className("android.view.View").text("展开更多数据").exists()){
        console.info("22222222");
        className("android.view.View").text("展开更多数据").findOne().click()
    }
    
    sleep(3000);
    console.info("----------------");

    if(className("android.view.View").depth(14).indexInParent(2).exists()){
        var today_viewed = className("android.view.View").depth(14).indexInParent(2).findOne().text();
        console.info(today_viewed);
        var today_contacted = className("android.view.View").depth(14).indexInParent(5).findOne().text();
        console.info(today_contacted);
        var today_get_resume = className("android.view.View").depth(14).indexInParent(11).findOne().text();
        console.info(today_get_resume);
        var today_wechat = className("android.view.View").depth(14).indexInParent(14).findOne().text();
        console.info(today_wechat);
        var today_interview = className("android.view.View").depth(14).indexInParent(17).findOne().text();
        console.info(today_interview);
        var today_communicate = className("android.view.View").depth(14).indexInParent(8).findOne().text();
        console.info(today_communicate);



        var compare_yester_viewed = className("android.view.View").depth(14).indexInParent(3).findOne().findOne(className("android.view.View").depth(15).indexInParent(2)).text();
        console.info(compare_yester_viewed);
        var compare_yester_contacted = className("android.view.View").depth(14).indexInParent(6).findOne().findOne(className("android.view.View").depth(15).indexInParent(2)).text();
        console.info(compare_yester_contacted);
        var compare_yester_get_resume = className("android.view.View").depth(14).indexInParent(12).findOne().findOne(className("android.view.View").depth(15).indexInParent(2)).text();
        var compare_yester_wechat = className("android.view.View").depth(14).indexInParent(15).findOne().findOne(className("android.view.View").depth(15).indexInParent(2)).text();
        var compare_interview = className("android.view.View").depth(14).indexInParent(18).findOne().findOne(className("android.view.View").depth(15).indexInParent(2)).text();
        var compare_communicate = className("android.view.View").depth(14).indexInParent(9).findOne().findOne(className("android.view.View").depth(15).indexInParent(2)).text();
    }else{
        var today_viewed = className("android.view.View").depth(6).indexInParent(2).findOne().text();
        console.info(today_viewed);
        var today_contacted = className("android.view.View").depth(6).indexInParent(5).findOne().text();
        console.info(today_contacted);
        var today_get_resume = className("android.view.View").depth(6).indexInParent(11).findOne().text();
        console.info(today_get_resume);
        var today_wechat = className("android.view.View").depth(6).indexInParent(14).findOne().text();
        console.info(today_wechat);
        var today_interview = className("android.view.View").depth(6).indexInParent(17).findOne().text();
        console.info(today_interview);
        var today_communicate = className("android.view.View").depth(6).indexInParent(8).findOne().text();
        console.info(today_communicate);



        var compare_yester_viewed = className("android.view.View").depth(6).indexInParent(3).findOne().findOne(className("android.view.View").depth(7).indexInParent(2)).text();
        console.info(compare_yester_viewed);
        var compare_yester_contacted = className("android.view.View").depth(6).indexInParent(6).findOne().findOne(className("android.view.View").depth(7).indexInParent(2)).text();
        console.info(compare_yester_contacted);
        var compare_yester_get_resume = className("android.view.View").depth(6).indexInParent(12).findOne().findOne(className("android.view.View").depth(7).indexInParent(2)).text();
        var compare_yester_wechat = className("android.view.View").depth(6).indexInParent(15).findOne().findOne(className("android.view.View").depth(7).indexInParent(2)).text();
        var compare_interview = className("android.view.View").depth(6).indexInParent(18).findOne().findOne(className("android.view.View").depth(7).indexInParent(2)).text();
        var compare_communicate = className("android.view.View").depth(6).indexInParent(9).findOne().findOne(className("android.view.View").depth(7).indexInParent(2)).text();










    }
    
    
    var payload = {"today_viewed": today_interview,
                   "compare_yester_viewed": compare_yester_viewed,
                   "today_contacted": today_contacted,
                   "compare_yester_contacted": compare_yester_contacted,
                   "today_get_resume": today_get_resume,
                   "compare_yester_get_resume": compare_yester_get_resume,
                   "today_wechat": compare_yester_wechat,
                   "compare_yester_wechat": compare_yester_wechat,
                   "today_interview": today_interview,
                   "compare_interview": compare_interview,
                   "today_communicate": today_communicate,
                   "compare_communicate": compare_communicate,
                   "boss_name": boss_name,
                   "company": company,
                   "report_time": report_time
                  }
    let res = http.postJson(url, JSON.stringify(payload));
    let html_content = res.body.string();  //取页面html源码
    let json_content = JSON.parse(html_content);
}
toast("Finished!!!");
close_app(appName);
