import 'package:flutter/material.dart';
import 'package:ruitoque/Models/campo.dart';
import 'package:ruitoque/constans.dart';

class CardItemCampo extends StatelessWidget {
  final Campo campo;
  final VoidCallback onTap;
  final bool isSelected;

  const CardItemCampo({
    super.key,
    required this.campo,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color borderColor = isSelected ? kPprimaryColor : Colors.black12;
    final Color bgColor = isSelected
        ? kPsecondaryColor
        : const Color.fromARGB(255, 248, 247, 247);
    final Color titleColor = isSelected ? Colors.white : kPcontrastMoradoColor;
    final Color subColor   = isSelected ? Colors.white70 : kPcontrastMoradoColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor, width: isSelected ? 2.5 : 1),
            boxShadow: [
              BoxShadow(
                color: isSelected ? kPprimaryColor.withOpacity(0.20) : Colors.black12,
                blurRadius: isSelected ? 18 : 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              // “Avatar” icónico del campo
              // Container(
              //   width: 42,
              //   height: 42,
              //   decoration: BoxDecoration(
              //     color: isSelected ? Colors.white.withOpacity(0.14) : Colors.white,
              //     borderRadius: BorderRadius.circular(12),
              //     border: Border.all(
              //       color: isSelected ? Colors.white30 : Colors.black12,
              //     ),
              //   ),
              //   child: Icon(
              //     Icons.golf_course_outlined,
              //     color: isSelected ? Colors.white : kPOcre,
              //   ),
              // ),
              const SizedBox(width: 12),

              // Texto principal
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título + pill Par
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            campo.nombre,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: kTextStyleNegroRobotoSize20.copyWith(
                              color: titleColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _ParPill(par: campo.par, selected: isSelected),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Ubicación (si existe)
                    if (campo.ubicacion.isNotEmpty)
                      Row(
                        children: [
                          Icon(Icons.place_outlined, size: 16, color: subColor),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              campo.ubicacion,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: subColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // Indicadores a la derecha
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: isSelected
                    ? const Icon(Icons.check_circle, key: ValueKey('ok'), color: Colors.white, size: 26)
                    : const Icon(Icons.chevron_right, key: ValueKey('next'), color: Colors.black45, size: 26),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ParPill extends StatelessWidget {
  final int par;
  final bool selected;
  const _ParPill({required this.par, required this.selected});

  @override
  Widget build(BuildContext context) {
    final bg = selected ? Colors.white.withOpacity(0.18) : Colors.black.withOpacity(0.06);
    final fg = selected ? Colors.white : Colors.black87;
    final bd = selected ? Colors.white30 : Colors.black12;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: bd),
      ),
      child: Text(
        'Par $par',
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
