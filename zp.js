let url = "https://us-central1-nexa-1181.cloudfunctions.net/zhipin"; //数据上传Google Storage

function slip(height,duration){
    //设备宽高度根据手机尺寸可调节
    var w1 = 2;
    var w2 = 2;
    var height_1=height;
    var height_2=0;
    //随机等待时间random（最小值，最大值）根据需要更改数值（单位秒）
    var time_random=random(1,5)*1000;
    swipe(device.width/w1,height_1,device.width/w2,height_2,duration);
    //提示等待时间。
    console.info("sleep ... " + time_random)
    sleep(time_random);
}



//获取所有已发布的职位
var position_tabs = id("scroll_view").findOne().children();
position_tabs.forEach(function(child, i){
    child.click();
    sleep(5000);
    console.info(child.text());
    persions(child.text(), i)
});

function browse_candidate(candidate_name, position){
    var flag = ""

    var working_year = id("tv_geek_work_year").findOne().text();
    console.info(working_year);
    var status = id("tv_geek_work_status").findOne().text();
    console.info(status);
    var degree = id("tv_geek_degree").findOne().text();
    console.info(degree);
    var salary = id("tv_salary").findOne().text();
    console.info(salary);
    var industry = id("tv_industry").findOne().text();
    console.info(industry);
    var desire_job = id("tv_job_and_city").findOne().text();
    console.info(desire_job);
    var school = "";
    var major = "";


    while(flag == ""){
        console.info("**********" + "信息下拉" + "**********");
        slip(2000, 10); //下滑
    
        if(id("tv_section_title").exists()){
            id("tv_section_title").find().forEach(function(currentValue, index) {
                if(currentValue.text() == "教育经历" || currentValue.text() == "看过Ta的人还联系了"  || currentValue.text() == "TA的回答"){
                    flag = currentValue.text();
                    console.info(flag);
                    console.info("===========" + "最后一次下拉" + "===========");
                    slip(2000, 10); //下滑
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
            "status": status,
            "working_year": working_year,
            "degree": degree,
            "salary": salary,
            "industry": industry,
            "desire_job": desire_job,
            "schoolS": school,
            "majors": major,
            "position": position
            }
    let res = http.postJson(url, JSON.stringify(payload));
    let html_content = res.body.string();  //取页面html源码
    let json_content = JSON.parse(html_content);
    toast(json_content);
}


function persions(position, position_index){
    var persions_list = []
    test = [1,2]
    test.forEach(function(){
        id("vp_fragment_tabs").findOne().children().forEach(function(child, i){
            if(i == position_index){
                var targets = child.find(className("android.widget.LinearLayout"));
                targets.forEach(function (currentValue, j){
                    var persons = currentValue.find(id("tv_geek_name"));
                    persons.forEach(function(item, k){
                        var abstract = item.text() + " " + position;
                        // console.info(abstract);
                        // console.info(persions_list);
                        if(persions_list.indexOf(abstract) == -1){
                            item.parent().click();
                            browse_candidate(item.text(), position);
                            sleep(3000);
                            persions_list.push(abstract);
                        }
                        
                    });
                });
            }
        });
        console.info("----------" + "牛人下拉" + "----------");
        // slip(2010,40);
        slip(1000,40);
    });
    console.error(persions_list);
}
