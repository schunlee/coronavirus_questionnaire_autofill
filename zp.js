let url = "https://us-central1-nexa-1181.cloudfunctions.net/zhipin"; //数据上传Google Storage

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
        lconsole.info(app.getAppName(name) + "应用不能被正常关闭或不在后台运行");
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

//浏览当前页面所有的牛人
function operate_candidate(child, position, persions_list, position_index, report_time, boss_company, boss_name){
    console.info("persions_list:" + persions_list.length);
    var targets = child.find(className("android.widget.LinearLayout"));
    targets.forEach(function (currentValue, j){
        console.info("##########");
        var persons = currentValue.find(id("tv_geek_name"));
        console.info("*************")
        // console.info(persons)
        persons.forEach(function(item, k){
            var abstract = item.text() + " " + position;
            console.info(abstract);
            toast(abstract);
            // console.info(abstract);
            // console.info(persions_list);
            if(persions_list.indexOf(abstract) === -1){
                if(item.parent().clickable()){
                    item.parent().click();
                }else{
                    item.parent().parent().click();
                }
                var sleep_time = 8000 + random(1,5)*1000;
                sleep(sleep_time);
                toast("sleep " + sleep_time);
                var person_keywords = id("tv_work_edu_other_desc").findOne().text();
                toast("tv_work_edu_other_desc" + person_keywords);
                console.info("tv_work_edu_other_desc" + person_keywords);

                browse_candidate(item.text(), position, position_index, persions_list.length, report_time, boss_company, boss_name, person_keywords);
                persions_list.push(abstract);
            }
            
        });
    });
}


// 下拉滚动更新牛人
function persons(position, position_index, report_time, boss_company, boss_name){
    var persions_list = []
    while(true){
        toast("hello" + id("vp_fragment_tabs").findOne().children().length);

        id("vp_fragment_tabs").findOne().children().forEach(function(child, i){
            console.info("child" + child.text());
            console.info("i" + i);
            console.info("position_index" + position_index);
            if(i === position_index){
                operate_candidate(child, position, persions_list, position_index, report_time, boss_company, boss_name);
            }
        });
        console.info("----------" + "牛人下拉" + "----------");
        toast("牛人下拉");
        slip(1000,0,40);
        if(persions_list.length > 30){
            console.error(persions_list);
            break
        }
    };
}


auto.waitFor();
var appName = "BOSS直聘";
launchApp(appName);

var sleep_time = 3000 + random(1,3)*1000;
sleep(sleep_time);
toast("sleep " + sleep_time);

console.info("sleep " + sleep_time);
toast("Launch app - " + appName);
console.info("Launch app - " + appName);

var home = id("cl_tab_4").findOne();
var boss_name = "";
var boss_company = "";

toast("home_button clickable" + home.clickable());
console.info("home_button clickable" + home.clickable());
if(home && home.clickable()){
    console.info("home");
    home.click();
    toast("Switch to `我的` tag");
    console.info("Switch to `我的` tag");

    var sleep_time = 4000 + random(1,3)*1000;
    sleep(sleep_time);
    toast("sleep " + sleep_time);

    id("rl_boss_base_info").findOne().click();
    var sleep_time = 3000 + random(1,3)*1000;
    sleep(sleep_time);
    toast("sleep " + sleep_time);

    boss_name = id("tv_name").findOne().text();
    toast("boss_name " + boss_name);
    console.info("boss_name " + boss_name);

    boss_company = id("tv_brand").findOne().text()
    toast("boss_company " + boss_company);
    console.info("boss_company " + boss_company);
    id("iv_back").findOne().click();
}else{
    toast("`我的` tag没找到耶，请关闭app重来盘");
    console.info("`我的` tag没找到耶，请关闭app重来盘");
}

var sleep_time = 3000 + random(1,3)*1000;
sleep(sleep_time);
toast("sleep " + sleep_time);

console.info("Get boss info finished.");
toast("Get boss info finished.");

// 进入牛人页面
var candidate = id("cl_tab_1").findOnce();
if (candidate && candidate.clickable()) {
    toast("Swicth to `牛人` tag");
    console.info("Swicth to `牛人` tag");
    candidate.click();
    var sleep_time = 4000 + random(1,5)*1000;
    sleep(sleep_time);
    toast("sleep " + sleep_time);

    //获取所有已发布的职位
    // var position_tabs = className("android.widget.FrameLayout").depth(18).find();
    if(className("android.widget.FrameLayout").depth(18).exists()){
        var position_tabs = className("android.widget.FrameLayout").depth(18).find();
    }else{
        var position_tabs = id("scroll_view").findOne().children();
    }

    console.info("position_tabs =>" + position_tabs.length);
    toast("position_tabs =>" + position_tabs.length);
    var report_time = CurentTime();
    position_tabs.forEach(function(child, j){
        if(child.clickable()){
            child.click();
        }else{
            child.children()[0].click();
        }
        
        // console.info(child.children()[0].click());
        var sleep_time = 5000 + random(1,5)*1000;
        sleep(sleep_time);
        toast("sleep " + sleep_time);
        toast("j" + j)
        if(child.text()){
            var position_name = child.text();
        }else{
            var position_name = child.children()[0].text();
        }
        toast(position_name);
        persons(position_name, j, report_time, boss_company, boss_name);
    });
}else{
    toast("Cannot find `牛人` tag");
    console.info("Cannot find `牛人` tag");
    }
var sleep_time = 3000 + random(1,4)*1000;
sleep(sleep_time);
toast("sleep " + sleep_time);
toast("Finished!!!");
console.info("Finished!!!");
close_app(appName);

//牛人信息全浏览，并抓取关键数据上传Aliyun
function browse_candidate(candidate_name, position, position_index, person_index, report_time, boss_company, boss_name, person_keywords){
    var flag = ""
    var internal_candidate_name = id("tv_geek_name").findOne().text(); //刷新牛人姓名，避免错名情况
    var working_year = id("tv_geek_work_year").findOne().text();
    console.info(working_year);
    var status = id("tv_geek_work_status").findOne().text();
    console.info(status);
    var degree = id("tv_geek_degree").findOne().text();
    console.info(degree);

    slip(1000, 920, 30); //下滑
    var sleep_time = 1000 + random(1,4)*1000;
    sleep(sleep_time);
    toast("sleep " + sleep_time);

    var salary = id("tv_salary").findOne().text();
    console.info("salary " + salary);
    toast("salary " + salary);
    var industry = id("tv_industry").findOne().text();
    console.info("tv_industry" + industry);
    toast("tv_industry" + industry);
    var desire_job = id("tv_job_and_city").findOne().text();
    console.info("tv_job_and_city" + desire_job);
    toast("tv_job_and_city" + desire_job);
    
    var school = "";
    var major = "";


    while(flag === ""){
        console.info("**********" + "信息下拉" + "**********");
        slip(1000, 0, 30); //下滑
    
        if(id("tv_section_title").exists()){
            id("tv_section_title").find().forEach(function(currentValue, index) {
                if(currentValue.text() === "教育经历" || currentValue.text() === "看过Ta的人还联系了"  || 
                currentValue.text() === "TA的回答" || currentValue.text() === "牛人分析器" || id("tv_edu_desc").exists()){
                    flag = currentValue.text();
                    console.info(flag);
                    console.info("===========" + "最后一次下拉" + "===========");
                    slip(1000, 0, 30); //下滑
                    var schools = id("tv_school").find();
                    var schools_list = []
                    schools.forEach(function(item, i){
                        schools_list.push(item.text())
                    });
                    school = schools_list.join(",")
                    console.info(school);

                    var majors = id("tv_degree_and_major").find();
                    var majors_list = []
                    majors.forEach(function(item, i){
                        majors_list.push(item.text())
                    });
                    major = majors_list.join(",")
                    console.info(major);
                }
            });
        }
    }
    console.info("browsed done: " + candidate_name);
    id("iv_back").findOne().click();
    payload = {
            "candidate_name": candidate_name,
            "internal_candidate_name": internal_candidate_name,
            "status": status,
            "working_year": working_year,
            "degree": degree,
            "salary": salary,
            "industry": industry,
            "desire_job": desire_job,
            "schools": school,
            "majors": major,
            "position": position,
            "position_index": position_index,
            "person_index": person_index,
            "report_time": report_time,
            "boss_name": boss_name,
            "boss_company": boss_company,
            "person_keywords": person_keywords
            }
    let res = http.postJson(url, JSON.stringify(payload));
    let html_content = res.body.string();  //取页面html源码
    let json_content = JSON.parse(html_content);
    console.info("Upload data to Aliyun.");
    toast("Upload data to Aliyun.");
}
