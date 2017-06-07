<template>
    <div>
        <div class="index">
            <h1>单一图像去雾在线演示</h1>
            <div v-if="state === 'upload'">
                <Upload type="drag" action="/upload" name="file_data"
                        :before-upload="handlePreupload"
                        :on-success="handleSuccess"
                        :on-remove="handleRemove">
                    <div style="padding: 20px 0">
                        <Icon type="ios-cloud-upload" size="52" style="color: #3399ff"></Icon>
                        <p>点击或将图片拖拽到这里上传</p>
                    </div>
                </Upload>
            </div>
            <div v-else>
                <p v-if="result.config.show_time">总耗时：{{ result.total_time}}s (计算耗时：{{ result.real_time }}s)</p>
                <p v-if="result.config.show_a">大气光值：{{ result.atmosphere }} <span v-if="result.config.show_time">计算耗时：{{ result.a_time }}s</span></p>
                <Row>
                    <Col class="image-block" span="12">
                        <p>原图</p>
                        <img style="max-width: 100%" :src="result.image_org" @click="showImage(result.image_org)">
                    </Col>
                    <Col class="image-block" span="12">
                        <p>去雾图 <span v-if="result.config.show_time">计算耗时：{{ result.res_time }}s</span></p>
                        <img style="max-width: 100%" :src="result.image_recover" @click="showImage(result.image_recover)">
                    </Col>
                </Row>
                <Row>
                    <Col class="image-block" v-if="result.config.show_dark" span="12">
                        <p>暗通道图 <span v-if="result.config.show_time">计算耗时：{{ result.dark_time }}s</span></p>
                        <img style="max-width: 100%" :src="result.image_dark" @click="showImage(result.image_dark)">
                    </Col>
                    <Col class="image-block" v-if="result.config.show_t" span="12">
                        <p>透射图 <span v-if="result.config.show_time">计算耗时：{{ result.t_time }}s</span></p>
                        <img style="max-width: 100%" :src="result.image_t" @click="showImage(result.image_t)">
                    </Col>
                </Row>
            </div>
            <Spin size="large" fix v-if="spinShow"></Spin>
            <br>
            <h2>设置</h2>
            <Row class="setting-block">
                <Col span="8">图像显示</Col>
                <Col span="8">预设参数</Col>
                <Col span="8">杂项</Col>
            </Row>
            <Row class="setting-block">
                <Col span="8">显示大气光值: <i-switch v-model="showA"></i-switch></Col>
                <Col span="8">细化透射率: <i-switch v-model="refine"></i-switch></Col>
                <Col span="8">显示耗时: <i-switch v-model="showTime"></i-switch></Col>
            </Row>
            <Row class="setting-block">
                <Col span="8">显示暗通道图像: <i-switch v-model="showDarkChannel"></i-switch></Col>
                <Col span="8">窗口大小
                    <Tooltip content="决定暗通道图像块大小（经典值：15）" placement="top">
                        <Icon type="ios-help" size="16" style="color: #3399ff"></Icon>
                    </Tooltip>:
                    <Input-number :max="1000" :min="1" v-model="windowSize"></Input-number>
                </Col>
            </Row>
            <Row class="setting-block">
                <Col span="8">显示透射率: <i-switch v-model="showTransmission"></i-switch></Col>
                <Col span="8">ω值
                    <Tooltip content="ω值即为去雾程度（经典值：95%）" placement="top">
                        <Icon type="ios-help" size="16" style="color: #3399ff"></Icon>
                    </Tooltip>:
                    <Input-number :max="100" :min="1" :step="1" v-model="omega"></Input-number>%
                </Col>
            </Row>
            <br>
            <div style="float: right; margin-bottom: 20px;">
                <Button v-if="state === 'result'" type="success" @click="gotoUpload">返回</Button>
                <Button type="primary" @click="processImage">处 理</Button>
            </div>
        </div>
        <div v-if="showFullImage" class="image-view" @click="dismissImage">
            <img :src="image" style="max-height: 100%; max-width: 100%; margin-top: 20px;"/>
        </div>
    </div>
</template>

<script>
    /*eslint no-console: 0 */
    import Util from '../libs/util';

    export default {
        data() {
            return {
                state: 'upload',
                spinShow: false,
                showDarkChannel: true,
                showA: true,
                showTransmission: true,
                showTime: true,
                refine: true,
                windowSize: 15,
                omega: 95,
                image_name: '',
                result: {},
                showFullImage: false,
                image: '',
            };
        },
        methods: {
            handlePreupload() {
                if (this.image_name !== '') {
                    this.$Modal.error({
                        title: '上传错误',
                        content: '只能上传一张图片'
                    });
                    return false;
                } else {
                    return true;
                }
            },
            handleSuccess(res) {
                this.image_name = res.name;
            },
            handleRemove() {
                this.image_name = '';
            },
            processImage() {
                if (this.image_name === '') {
                    this.$Modal.error({
                        title: '请求错误',
                        content: '请上传图片',
                    });
                } else {
                    this.spinShow = true;
                    const data = {
                        show_dark: this.showDarkChannel,
                        show_a: this.showA,
                        show_t: this.showTransmission,
                        show_time: this.showTime,
                        refine: this.refine,
                        window_size: this.windowSize,
                        omega: this.omega,
                    };
                    Util.ajax.post(`/${this.image_name}`, data).then((res) => {
                        this.result = res.data;
                        this.state = 'result';
                        this.spinShow = false;
                    }).catch((error) => {
                        this.spinShow = false;
                        this.$Modal.error({
                            title: '请求错误',
                            content: error
                        });
                    });
                }
            },
            gotoUpload() {
                this.state = 'upload';
                this.image_name = '';
            },
            showImage(image) {
                this.image = image;
                this.showFullImage = true;
            },
            dismissImage() {
                this.image = '';
                this.showFullImage = false;
            },
        }
    };
</script>

<style scoped>
    .index {
        width: 100%;
        height: 100%;
        padding-left: 3%;
        padding-right: 3%;
        font-size: 14px;
    }

    .index h1 {
        height: 100px;
        line-height: 100px;
        text-align: center;
    }

    .setting-block {
        margin-bottom: 10px;
    }

    .image-block {
        text-align: center;
    }

    .image-view {
        position: fixed;
        top: 0;
        bottom: 0;
        left: 0;
        right: 0;
        background-color: black;
        height: 100%;
        z-index: 1000;
        text-align: center;
    }
</style>