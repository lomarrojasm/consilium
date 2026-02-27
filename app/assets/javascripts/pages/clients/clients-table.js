// app/assets/javascripts/pages/clients/clients-table.js

$(document).on('turbo:load', function () {
    "use strict";

    var tableId = "#clients-datatable";

    // 1. Limpieza para evitar duplicados al navegar
    if ($.fn.DataTable.isDataTable(tableId)) {
        $(tableId).DataTable().destroy();
    }

    // 2. Inicialización Directa
    $(tableId).DataTable({
        // La 'B' es la que activa los botones. El resto es el diseño de Hyper.
        language: {
            paginate: {
                previous: "<i class='mdi mdi-chevron-left'>",
                next: "<i class='mdi mdi-chevron-right'>"
            },
            search: "Buscar",
            info: "Mostrando Clientes _START_ a _END_ de _TOTAL_",
            lengthMenu: " Mostrar _MENU_ Clientes"
        },
        columnDefs: [
            {
                targets: -1,
                className: 'dt-body-right'
            }
        ],
        pageLength: 10,
        columns: [
            { orderable: false }, // Logo
            { orderable: true },  // Razón Social
            { orderable: true },  // RFC
            { orderable: true },  // Industria
            { orderable: true },  // Contacto
            { orderable: false },  // Timeline
        ],
        order: [[1, "asc"]],
        drawCallback: function () {
            $(".dataTables_paginate > .pagination").addClass("pagination-rounded");
            $('#clients-datatable_length label').addClass('form-label');

            // Ajuste de columnas para que se vea bien en Hyper (Tu lógica original)
            var wrapper = document.querySelector('.dataTables_wrapper');
            if (wrapper) {
                var rows = wrapper.querySelectorAll('.row');
                if (rows.length > 0) {
                    rows[0].querySelectorAll('.col-md-6').forEach(function (element) {
                        element.classList.add('col-sm-6');
                        element.classList.remove('col-md-6');
                    });
                }
            }
        }
    });
});