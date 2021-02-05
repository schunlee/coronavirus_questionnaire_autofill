let url = "https://us-central1-nexa-1181.cloudfunctions.net/zhipin_positions";

function slip(height,height2, duration){
    //设备宽高度根据手机尺寸可调节
    var w1 = 2;
    var w2 = 2;
    var height_1=height;
    var height_2=height2;
    //随机等待时间random（最小值，最大值）根据需要更改数值（单位秒）
    var time_random=random(1,5)*1000;
    swipe(device.width/w1,height_1,device.width/w2,height_2,duration);
    //提示等待时间。
    console.info("sleep ... " + time_random)
    sleep(time_random);
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
        if(id("right_button").exists()){
            id("right_button").click();
        }
        
        sleep(3000)
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

function list_jobs(job_count){
    console.info("开始爬取职位信息...");
    toast("开始爬取职位信息...");
    var jobs_list = [];
    var job_status = "";
    var crawl_index = 0;
    while(true){
        var sleep_time = 3000 + random(1,3)*1000;
        sleep(sleep_time);
        toast("sleep " + sleep_time);
        if(className("android.view.ViewGroup").depth(4).exists()){
            var jobs = className("android.view.ViewGroup").depth(4).find();
        }else{
            var jobs = className("android.view.ViewGroup").depth(12).find();
        }
        
        console.info("jobs length => " + jobs.length);
        toast("jobs length => " + jobs.length);

        jobs.forEach(function(job_item, item_index){
            var sleep_time = 4000 + random(1,3)*1000;
            sleep(sleep_time);
            toast("sleep " + sleep_time);

            // console.info(job_item.find(id("tv_job_name").indexInParent(item_index))[0].text())
            if(job_item.find(id("tv_job_name")).length){
                var job_name_obj = job_item.find(id("tv_job_name"))[0];
            }else{
                console.info(job_item.findOne(id("tv_job_name")))
                var job_name_obj = job_item.find(id("tv_job_name"));
            }

            console.info("type" + typeof(job_name_obj));
            try{
                var job_name = job_name_obj.text();
                toast("job_name " + job_name);
                console.info(jobs_list);
                
                if(id("tv_job_state").exists()){
                    job_status = id("tv_job_state").findOne().text();
                }

                console.info("job_item_clickable: " + job_item.clickable());
                job_item.click();
                var sleep_time = 3000 + random(1,3)*1000;
                sleep(sleep_time);
                toast("sleep " + sleep_time);
                payload = browse_job();
                payload.report_time = report_time;
                payload.boss_name = boss_name;
                payload.company = company;
                payload.job_name = job_name;
                payload.job_status = job_status;

                if(jobs_list.indexOf(job_name + payload.contacted_count + payload.viewed_count + payload.like_count + payload.shared_count + payload.job_type) === -1){
                    payload.crawl_index = crawl_index;
                    let res = http.postJson(url, JSON.stringify(payload));
                    let html_content = res.body.string();  //取页面html源码
                    let json_content = JSON.parse(html_content);
                    console.info("Upload data to aliyun");
                    toast("Upload data to aliyun");
                    crawl_index = crawl_index + 1;
                    jobs_list.push(job_name + payload.contacted_count + payload.viewed_count + payload.like_count + payload.shared_count + payload.job_type);
                } 
            }catch (e){
                
            }
            
            
            // }

            
            
            }
        );
        var sleep_time = 3000 + random(1,3)*1000;
        sleep(sleep_time);
        toast("sleep " + sleep_time);
        console.info("-----------下拉----------");
        toast("职位下拉 ...")
        slip(1000, 970, 30);
        var sleep_time = 5000 + random(1,3)*1000;
        sleep(sleep_time);
        toast("sleep " + sleep_time);

        if(job_status){
            toast("退出循环");
            break;
   
        }
    }
}

function browse_job(){
    var flag = "";
    while(flag == ""){
        console.info("---------------------------------")
        toast("职位具体信息爬取 ...");
        var internal_job_name = id("tv_job_name").findOne().text();
        var job_desp = id("tv_description").findOne().text();
        var job_type = id("tv_banner_title").findOne().text();

        if(className("android.widget.LinearLayout").depth(3).find()[1]){
            var base = className("android.widget.LinearLayout").depth(3).find()[1];
            var keywords = base.find(className("android.widget.FrameLayout").depth(4));
        }else{
            var base = className("android.widget.LinearLayout").depth(3).find()[1];
            var keywords = className("android.widget.FrameLayout").depth(11).find();
        }
        
        var keywords_list = [];
        keywords.forEach(function(item, item_index){
            keywords_list.push(item.findOne(className("android.widget.TextView")).text());
        });
        slip(1000, 0, 30); //下滑
        toast("下拉 ...");

        flag = id("tv_job_related_info_title").findOne().text();

        var contacted_count = id("tv_job_contacted_count").findOne().text();
        console.info("沟通过 " + contacted_count);
        toast("沟通过 " + contacted_count);
        var viewed_count = id("tv_job_viewed_count").findOne().text();
        console.info("查看过 " + viewed_count);
        toast("查看过 " + viewed_count);
        var like_count = id("tv_job_like_count").findOne().text();
        console.info("感兴趣 " + like_count);
        toast("感兴趣 " + like_count);
        var shared_count = id("tv_job_shared_count").findOne().text();
        console.info("分享查看 " + shared_count);
        toast("分享查看 " + shared_count);

        id("iv_back").findOne().click();
        toast("返回职位列表");
        console.info("返回职位列表");

        return {"internal_job_name": internal_job_name,
                "job_desp": job_desp,
                "keywords": keywords_list.join(","),
                "contacted_count": contacted_count,
                "viewed_count": viewed_count,
                "like_count": like_count,
                "shared_count": shared_count,
                "job_type": job_type
                }
    }
}



auto.waitFor();
var appName = "BOSS直聘";
launchApp(appName);
var sleep_time = 4000 + random(1,3)*1000;
sleep(sleep_time);
toast("sleep " + sleep_time);
toast("Launch app - " + appName);

var report_time = CurentTime();

var home = id("cl_tab_4").findOnce();

toast("home_button clickable" + home.clickable());
console.info("home_button clickable" + home.clickable());
if(home && home.clickable()){
    home.click();
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
    var sleep_time = 4000 + random(1,3)*1000;
    sleep(sleep_time);
    toast("sleep " + sleep_time);

    if(className("android.widget.ScrollView").depth(1).indexInParent(5).exists()){
        console.info("UI => 2")
        var job_count = className("android.widget.ScrollView").depth(1).indexInParent(5).findOne().find(className("android.widget.TextView"))[0].text();
        console.info("开放职位数: " + job_count);
        toast("开放职位数: " + job_count);
        className("android.widget.ScrollView").depth(1).indexInParent(5).findOne().find(className("android.widget.TextView"))[0].parent().click();
    }else{
        console.info("UI => 1")
        var job_count = className("android.widget.LinearLayout").depth(13).indexInParent(0).find()[1].findOne(id("tvPositionCount")).text();
        console.info("开放职位数: " + job_count);
        toast("开放职位数: " + job_count);
        className("android.widget.LinearLayout").depth(13).indexInParent(0).find()[1].children()[0].click();
    }
    var sleep_time = 5000 + random(1,3)*1000;
    sleep(sleep_time);
    toast("sleep " + sleep_time);
    console.info("*****************")
    list_jobs(job_count)
}else{
    toast("`我的` tag没找到耶，请关闭app重来盘");
    console.info("`我的` tag没找到耶，请关闭app重来盘");
}
var sleep_time = 3000 + random(1,4)*1000;
sleep(sleep_time);
toast("sleep " + sleep_time);
toast("Finished!!!");
console.info("Finished!!!");
close_app(appName);
