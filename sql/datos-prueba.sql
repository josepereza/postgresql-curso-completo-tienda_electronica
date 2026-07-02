-- ============================================================
-- DATOS DE PRUEBA
-- Sistema Profesional de Tienda Electrónica
-- ============================================================

-- Limpiar datos anteriores (opcional)
-- DELETE FROM ventas.detalles_orden;
-- DELETE FROM ventas.ordenes;
-- DELETE FROM public.usuarios;
-- DELETE FROM public.productos;

-- ============================================================
-- INSERTAR USUARIOS
-- ============================================================

INSERT INTO public.usuarios (email, nombre, rol)
VALUES
    ('juan@tienda.com', 'Juan Pérez', 'cliente'),
    ('maria@tienda.com', 'María García', 'gerente'),
    ('carlos@tienda.com', 'Carlos López', 'cliente'),
    ('sofia@tienda.com', 'Sofía Martínez', 'gerente'),
    ('pedro@tienda.com', 'Pedro Ramírez', 'cliente')
ON CONFLICT DO NOTHING;

-- ============================================================
-- INSERTAR PRODUCTOS
-- ============================================================

INSERT INTO public.productos (nombre, descripcion, precio, stock, categoria)
VALUES
    ('Laptop Dell', 'Laptop 15 pulgadas, 16GB RAM, 256GB SSD', 800.00, 10, 'Electrónica'),
    ('Mouse Logitech', 'Mouse inalámbrico USB', 25.00, 50, 'Accesorios'),
    ('Teclado Mecánico', 'Teclado RGB Cherry MX', 120.00, 30, 'Accesorios'),
    ('Monitor LG 27"', 'Monitor IPS 4K USB-C', 350.00, 15, 'Electrónica'),
    ('Headset HyperX', 'Auriculares gaming 7.1', 150.00, 20, 'Accesorios'),
    ('Webcam Logitech', 'Cámara 4K para video conferencias', 100.00, 25, 'Accesorios'),
    ('SSD Samsung 1TB', 'Unidad SSD NVMe 1TB', 120.00, 40, 'Almacenamiento'),
    ('RAM 16GB', 'Memoria RAM DDR4 16GB 3200MHz', 80.00, 35, 'Componentes')
ON CONFLICT DO NOTHING;

-- ============================================================
-- INSERTAR ÓRDENES Y DETALLES
-- ============================================================

-- Orden 1: Juan compra Laptop y Mouse
INSERT INTO ventas.ordenes (usuario_id, estado)
VALUES (1, 'pagado')
ON CONFLICT DO NOTHING
RETURNING id AS orden_id;

INSERT INTO ventas.detalles_orden (orden_id, producto_id, cantidad, precio_unitario, subtotal)
VALUES
    (1, 1, 1, 800.00, 800.00),
    (1, 2, 2, 25.00, 50.00)
ON CONFLICT DO NOTHING;

-- Orden 2: Carlos compra Teclado y Monitor
INSERT INTO ventas.ordenes (usuario_id, estado)
VALUES (3, 'pagado')
RETURNING id AS orden_id;

INSERT INTO ventas.detalles_orden (orden_id, producto_id, cantidad, precio_unitario, subtotal)
VALUES
    (2, 3, 1, 120.00, 120.00),
    (2, 4, 1, 350.00, 350.00)
ON CONFLICT DO NOTHING;

-- Orden 3: Pedro hace compra pendiente
INSERT INTO ventas.ordenes (usuario_id, estado)
VALUES (5, 'pendiente')
RETURNING id AS orden_id;

INSERT INTO ventas.detalles_orden (orden_id, producto_id, cantidad, precio_unitario, subtotal)
VALUES
    (3, 5, 1, 150.00, 150.00),
    (3, 6, 1, 100.00, 100.00)
ON CONFLICT DO NOTHING;

-- ============================================================
-- VERIFICACIÓN
-- ============================================================

-- Contar registros
-- SELECT COUNT(*) as usuarios FROM public.usuarios;
-- SELECT COUNT(*) as productos FROM public.productos;
-- SELECT COUNT(*) as ordenes FROM ventas.ordenes;
-- SELECT COUNT(*) as detalles FROM ventas.detalles_orden;

-- Ver órdenes con totales
-- SELECT o.id, u.nombre, o.estado, o.total, o.created_at
-- FROM ventas.ordenes o
-- JOIN public.usuarios u ON o.usuario_id = u.id
-- ORDER BY o.created_at DESC;
