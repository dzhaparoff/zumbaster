(function(){
    "use strict";
    angular
        .module('admin')
        .directive('blurBg', blurBg)


    blurBg.$inject = [];

    function blurBg(){
        return {
            restrict : "AE",
            link : function(scope, elem, attr){
                var BLUR_RADIUS = 30;

                var image = new Image();
                var image_element = document.querySelector('[data-canvas-image]');
                var size, w, h, document_size, left, top, zfX, zfY, diffX, diffY, document_ar, image_ar;
                image.src = document.querySelector('[data-canvas-image]').src;

                var canvas = document.getElementById('innerBlurBg');
                var canvasContext = canvas.getContext('2d');

                var image_size = {
                    width  : $(image_element).attr('data-width'),
                    height : $(image_element).attr('data-height')
                };

                var drawBlur = function() {
                    size = document.getElementById('innerBlurBg').getBoundingClientRect();
                    w = canvas.width;
                    h = canvas.height;

                    document_size = {
                        width  : document.body.clientWidth,
                        height : document.body.clientHeight
                    };

                    diffX = image_size.width / document_size.width;
                    diffY = image_size.height / document_size.height;

                    document_ar = document_size.width/document_size.height;
                    image_ar = image_size.width/image_size.height;

                    if(document_ar > image_ar) {
                        left = size.left * diffX;
                        top = (size.top + (image_size.height/diffX - document_size.height)/2) * diffX;
                        zfX = size.width * diffX;
                        zfY = size.height * diffX;
                    }
                    if(document_ar < image_ar) {
                        left = (size.left + (image_size.width/diffY - document_size.width)/2) * diffY;
                        top = size.top * diffY;
                        zfX = size.width * diffY;
                        zfY = size.height * diffY;
                    }
                    if(document_ar == image_ar) {
                        left = size.left * diffX;
                        top = size.top * diffY;
                        zfX = size.width;
                        zfY = size.height;
                    }
                    canvasContext.drawImage(image, left, top, zfX, zfY, 0, 0, w, h);
                    stackBlurCanvasRGB('innerBlurBg', 0, 0, w, h, BLUR_RADIUS);
                    //canvasContext.fillStyle = "rgba(255,255,255,0.4)";
                    //canvasContext.fillRect(0,0,w,h);
                };

                image.onload = function() {
                    drawBlur();
                };

                window.addEventListener("resize", function(){
                    drawBlur();
                })
            }
        }
    }
})();