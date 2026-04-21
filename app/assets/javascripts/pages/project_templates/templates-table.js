// app/assets/javascripts/pages/project_templates/templates-table.js

$(document).on('turbo:load', function () {
    "use strict";

    var tableId = "#project-templates-datatable";

    // 1. Limpieza para evitar duplicados al navegar con Turbo
    if ($.fn.DataTable.isDataTable(tableId)) {
        $(tableId).DataTable().destroy();
    }

    // 2. Inicialización Directa
    $(tableId).DataTable({
        language: {
            paginate: {
                previous: "<i class='mdi mdi-chevron-left'>",
                next: "<i class='mdi mdi-chevron-right'>"
            },
            search: "Buscar Plantilla:",
            info: "Mostrando Metodologías _START_ a _END_ de _TOTAL_",
            lengthMenu: " Mostrar _MENU_ Metodologías",
            infoEmpty: "Mostrando 0 a 0 de 0 Metodologías",
            zeroRecords: "No se encontraron metodologías coincidentes"
        },
        columnDefs: [
            {
                targets: -1, // La última columna (Acciones)
                className: 'text-end',
                orderable: false // No queremos ordenar por los botones
            },
            {
                targets: [1, 2], // Columnas de Etapas y Tareas
                className: 'text-center'
            }
        ],
        pageLength: 10,
        columns: [
            { orderable: true },  // Nombre de la Metodología
            { orderable: true },  // Etapas
            { orderable: true },  // Total Tareas
            { orderable: false }  // Acciones
        ],
        order: [[0, "asc"]], // Ordenar por nombre alfabéticamente por defecto
        drawCallback: function () {
            // Estilos de Hyper / Bootstrap 5 para la paginación y el buscador
            $(".dataTables_paginate > .pagination").addClass("pagination-rounded");
            $(tableId + '_length label').addClass('form-label');
            $(tableId + '_filter label').addClass('form-label');

            // Ajuste de columnas para responsividad (Lógica original de Hyper)
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