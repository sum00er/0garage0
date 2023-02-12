

(function () {
    'use strict'
    var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'))
    tooltipTriggerList.forEach(function (tooltipTriggerEl) {
        new bootstrap.Tooltip(tooltipTriggerEl)
    })
})()


$(".nav-home").click(function () {
    $(".pages").css("display", "none");
    $(".homepage").css("display", "block");
    $(".nav").removeClass("active nav-item");
    $(".nav-home").addClass("active nav-item");
})
$(".nav-impound").click(function () {
    $(".pages").css("display", "none");
    $(".impoundpage").css("display", "block");
    $(".nav").removeClass("active nav-item");
    $(".nav-impound").addClass("active nav-item");
})
$(".nav-search").click(function () {
    $(".pages").css("display", "none");
    $(".searchpage").css("display", "block");
    $(".nav").removeClass("active nav-item");
    $(".nav-search").addClass("active nav-item");
})



$(window).ready(function () {
    window.addEventListener('message', function (event) {
        let data = event.data

        if (data.show) {
            $("#body").fadeIn()
        }
        if (data.close) {
            $("#body").fadeOut();
        }
        if (data.type === 'garage') {
            $(".pages").css("display", "none");
            $(".homepage").css("display", "block");
            $(".nav").removeClass("active nav-item");
            $(".nav-home").addClass("active nav-item");
            if (data.vehiclesList != undefined) {

                $('#container').data('spawnpoint', data.spawnPoint)
                $('.vehicle').html(
                    getVehicles(data.vehiclesList, 'garage', 'garage')
                )
                $('.no-vehicle').css("display", "none");
            } else {
                $('.vehicle').html("");
                $('.no-vehicle').css("display", "block");
            }
            if (data.vehiclesImpoundedList != undefined) {
                $('.impound').html(
                    getVehicles(data.vehiclesImpoundedList, 'impound', 'garage')
                )
                $('.no-vehicle-impound').css("display", "none");
            } else {
                $('.impound').html("");
                $('.no-vehicle-impound').css("display", "block");
            }
        } else if (data.type === 'impound') {
            if (data.vehiclesList != undefined) {
                $('#container').data('spawnpoint', data.spawnPoint);
                $('.vehicle').html(
                    getVehicles(data.vehiclesList, 'garage', 'impound')
                );
                $('.impound').html(
                    getVehicles(data.vehiclesImpoundedList, 'impound', 'impound')
                );
                $('.no-vehicle').css("display", "none");
            } else {
                $('#container').data('spawnpoint', data.spawnPoint);
                $('.vehicle').html("");
                $('.impound').html(
                    getVehicles(data.vehiclesImpoundedList, 'impound', 'impound')
                );
                $('.no-vehicle').css("display", "block");
            }
            $(".pages").css("display", "none");
            $(".impoundpage").css("display", "block");
            $(".nav").removeClass("active nav-item");
            $(".nav-impound").addClass("active nav-item");
        }
        function getVehicles(vehicle, type, action) {
            let html = ''
            let vehicleData = JSON.parse(vehicle)
            let bodyHealth = 1000
            let engineHealth = 1000
            let tankHealth = 1000
            let vehicleDamagePercent = ''

            for (let i = 0; i < vehicleData.length; i++) {
                bodyHealth = (vehicleData[i].props.bodyHealth / 1000) * 100
                engineHealth = (vehicleData[i].props.engineHealth / 1000) * 100
                if (vehicleData[i].props.tankHealth != undefined) {
                    tankHealth = (vehicleData[i].props.tankHealth / 1000) * 100
                    vehicleDamagePercent =
                        Math.round(((bodyHealth + engineHealth + tankHealth) / 300) * 100) + '%'
                } else {
                    vehicleDamagePercent =
                        Math.round(((bodyHealth + engineHealth) / 200) * 100) + '%'
                }
                html += '<div class="card mb-3 bg-dark shadow rounded vehicle"><div class="row g-0"><div class="col-md-4">'
                html += '<img src="https://imgur.com/h5Qj1Si.png" class="card-img-top" alt="" height=100% width=120px style="object-fit: cover; overflow: hidden;">'
                html += '</div><div class="col-md-8"><div class="card-body">'
                html += '<h5 class="card-title text-light"><b> ' + vehicleData[i].model + ' </b>'
                html += '</h5><p class="card-text text-light" style="margin-bottom: 0.5px; font-size: 14px;">' + data.locales.carplate + '：<span class="plate">' + vehicleData[i].plate + '</span></p>'
                html += '<p class="card-text text-light" style="margin-bottom: 0.5px; font-size: 14px;">' + data.locales.health + '：<span class="breaklevel">' + vehicleDamagePercent + '</span></p>'
                html += '<p class="card-text text-light" style="margin-bottom: 10px; font-size: 14px;">' + data.locales.fuel + '：<span class="breaklevel">' + vehicleData[i].props.fuelLevel + '%</span></p>'
                if (action === type) {
                    html += "<div class='btn-group me-2' role='group'><button class='btn btn-primary shadow-none mr-1 vehicle-action-spawn text-light' data-vehprops='" + JSON.stringify(vehicleData[i].props) + "' data-toggle='tooltip' data-placement='top' title='" + data.locales.retrieve + "'><i class='fa-solid fa-car'></i></button></div>"
                }
                html += '<div class="btn-group me-2" role="group" data-toggle="tooltip" data-placement="top" title="' + data.locales.uploadphoto + '"><button class="btn btn-primary shadow-none upload-start text-light" disabled><i class="fa-solid fa-image"></i></button></div>'
                html += '<div class="btn-group me-2" role="group" data-toggle="tooltip" data-placement="top" title="' + data.locales.rename + '"><button class="btn btn-primary shadow-none rename-start text-light" disabled><i class="fa-solid fa-pen-to-square"></i></button></div></div></div></div></div>'
            }

            return html
        }

        $(".vehicle-action-spawn").click(function () {
            let spawnPoint = $('#container').data('spawnpoint')
            let vehicleProps = $(this).data('vehprops')

            $.post(
                'https://0garage0/spawnVehicle',
                JSON.stringify({
                    vehicleProps: vehicleProps,
                    spawnPoint: spawnPoint
                })
            )
            $.post('https://0garage0/close', '{}')
        }
        )
        $(function () {
            $('[data-toggle="tooltip"]').tooltip({
                trigger: 'hover'
            });

            $('[data-toggle="tooltip"]').on('click', function () {
                $(this).tooltip('hide')
            });
        })
    })
    document.onkeyup = function (data) {
        if (data.keyCode == 27) {
            $.post('https://0garage0/close', '{}')
        }
    }

})
