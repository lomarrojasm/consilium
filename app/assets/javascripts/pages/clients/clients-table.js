/**
 * Theme: Hyper - Responsive Bootstrap 5 Admin Dashboard
 * Author: Coderthemes
 * Module/App: Customers demo page
 */

$(document).ready(function () {
  "use strict";

  // Default Datatable
  $("#clients-datatable").DataTable({
    language: {
      paginate: {
        previous: "<i class='mdi mdi-chevron-left'>",
        next: "<i class='mdi mdi-chevron-right'>"
      },
      search: "Buscar",
      info: "Mostrando Clientes _START_ to _END_ of _TOTAL_",
      lengthMenu:
        " Mostrar <select class='form-select form-select-sm ms-1 me-1'>" +
        '<option value="10">10</option>' +
        '<option value="20">20</option>' +
        '<option value="-1">All</option>' +
        "</select> Clientes"
    },
    columnDefs: [
      {
        targets: -1,
        className: 'dt-body-right'
      }],
    pageLength: 10,
    columns: [
      { orderable: false },
      { orderable: true },
      { orderable: true },
      { orderable: true },
      { orderable: true },
      { orderable: true },
      { orderable: true },
      { orderable: false }
    ],
    order: [[1, "asc"]],
    drawCallback: function () {
      $(".dataTables_paginate > .pagination").addClass("pagination-rounded");
      $('#clients-datatable_length label').addClass('form-label');


      // Col add & remove
      var filterDiv = document.querySelector('.dataTables_wrapper .row');
      filterDiv.querySelectorAll('.col-md-6').forEach(function (element) {
        element.classList.add('col-sm-6');
        element.classList.remove('col-sm-12');
        element.classList.remove('col-md-6');
      });

    }
  });
});
